import Container from "./container";

function Footer() {
  return (
    <footer className="bg-neutral-50 border-t border-neutral-200">
      <Container>
        <div className="py-28 flex flex-col lg:flex-row items-center justify-between">
          {/* Left side: Name and info */}
          <div className="flex flex-col items-center lg:items-start lg:w-3/4">
            <h3 className="text-2xl lg:text-[2rem] font-extrabold tracking-tighter leading-tight text-center lg:text-left mb-2 text-black">
              PureHouse - Production DevOps Portfolio
            </h3>
            <div className="flex flex-col lg:flex-row items-center lg:items-baseline mb-4 lg:gap-4">
              <span className="text-[1rem] lg:text-xl text-center lg:text-left">Julian Dicante</span>
              <span className="text-[0.8rem] lg:text-[1.1rem] text-center lg:text-left lg:ml-2 mt-1 lg:mt-0">
                DevOps Engineer | Cloud Architecture
              </span>
            </div>
          </div>
          {/* Right side: Contact info */}
          <div className="flex flex-col items-center lg:items-end lg:w-1/2 mt-8 lg:mt-0">
            <a
              href="mailto:juliandicante@outlook.com"
              className="mx-3 text-sm lg:text-lg text-neutral-400 transition-all duration-200 hover:underline hover:text-black flex items-center group"
              aria-label="Contact"
            >
              {/* Inline SVG mail icon */}
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className="w-5 h-5 mr-2 stroke-current transition-colors duration-200 group-hover:text-black"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                strokeWidth={1.5}
                aria-hidden="true"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M3 8l7.89 5.26a3 3 0 003.22 0L22 8m-19 8V8a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2z"
                />
              </svg>
              juliandicante@outlook.com
            </a>
          </div>
        </div>
      </Container>
    </footer>
  );
}

export default Footer;
