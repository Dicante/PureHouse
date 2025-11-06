/* eslint-disable @next/next/no-img-element */
import Link from "next/link";

function Intro() {
  return (
    <section className="flex-col md:flex-row flex items-center md:justify-between mt-16 mb-16 md:mb-12">
      <div className="flex flex-row items-center gap-4">
        <img
          src="/logo-black.png"
          alt="Logo"
          className="w-10 h-10 md:w-18 md:h-18 shrink-0"
          width={128}
          height={128}
        />
        <h1 className="text-5xl md:text-8xl font-bold tracking-tighter leading-tight md:pr-8">PureHouse</h1>
      </div>

      <Link href={`/posts/new`} aria-label={"Add new post"}>
        <h4 className="text-center md:text-left text-lg mt-5 md:pl-8 hover:underline">Add new post</h4>
      </Link>
    </section>
  );
}

export default Intro;
