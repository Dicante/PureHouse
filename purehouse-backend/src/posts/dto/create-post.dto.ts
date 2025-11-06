import { IsString, IsOptional, MaxLength, IsObject } from 'class-validator';

export class CreatePostDto {
  @IsString()
  @MaxLength(80)
  title: string;

  @IsString()
  @MaxLength(30)
  author: string;

  @IsString()
  content: string;

  @IsOptional()
  @IsString()
  @MaxLength(250)
  excerpt?: string;

  @IsOptional()
  @IsObject()
  coverImage?: { url: string };

  @IsOptional()
  @IsObject()
  coverVideo?: { url: string };
}
