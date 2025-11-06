#############################################################################
# VPC Module - Main Configuration
#############################################################################
# This file creates the core networking infrastructure:
# - VPC (Virtual Private Cloud)
# - Public and Private Subnets across multiple Availability Zones
# - Internet Gateway for public internet access
# - NAT Gateway (optional) for private subnet internet access
# - Route Tables and associations
#############################################################################

#############################################################################
# VPC
#############################################################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-vpc"
      Project     = var.project_name
      Environment = var.environment
    },
    var.tags
  )
}

#############################################################################
# Internet Gateway (for public subnets)
#############################################################################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-igw"
      Project     = var.project_name
      Environment = var.environment
    },
    var.tags
  )
}

#############################################################################
# Public Subnets
#############################################################################

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name                                            = "${var.project_name}-${var.environment}-public-${var.availability_zones[count.index]}"
      Project                                         = var.project_name
      Environment                                     = var.environment
      "kubernetes.io/role/elb"                        = "1"
      "kubernetes.io/cluster/${var.project_name}-${var.environment}" = "shared"
    },
    var.tags
  )
}

#############################################################################
# Private Subnets
#############################################################################

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name                                            = "${var.project_name}-${var.environment}-private-${var.availability_zones[count.index]}"
      Project                                         = var.project_name
      Environment                                     = var.environment
      "kubernetes.io/role/internal-elb"               = "1"
      "kubernetes.io/cluster/${var.project_name}-${var.environment}" = "shared"
    },
    var.tags
  )
}

#############################################################################
# Elastic IP for NAT Gateway (only if NAT is enabled)
#############################################################################

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0

  domain = "vpc"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-eip-nat-${count.index + 1}"
      Project     = var.project_name
      Environment = var.environment
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.main]
}

#############################################################################
# NAT Gateway (optional, for private subnet internet access)
#############################################################################

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-nat-${count.index + 1}"
      Project     = var.project_name
      Environment = var.environment
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.main]
}

#############################################################################
# Route Table for Public Subnets
#############################################################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-public-rt"
      Project     = var.project_name
      Environment = var.environment
    },
    var.tags
  )
}

# Route to Internet Gateway
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#############################################################################
# Route Tables for Private Subnets
#############################################################################

resource "aws_route_table" "private" {
  count = var.single_nat_gateway ? 1 : length(var.availability_zones)

  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-private-rt-${count.index + 1}"
      Project     = var.project_name
      Environment = var.environment
    },
    var.tags
  )
}

# Route to NAT Gateway (only if NAT is enabled)
resource "aws_route" "private_nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

# Associate private subnets with private route tables
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.single_nat_gateway ? 0 : count.index].id
}
