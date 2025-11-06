import Avatar from "./avatar";
import CoverImage from "./cover-image";
import { type Post } from "../interfaces";
import Link from "next/link";
import DateFormatter from "./date-formatter";

function HeroPost({ post }: { post: Post }) {
  return (
    <section>
      <div className="mb-8 md:mb-16">
        <CoverImage
          title={post.title}
          src={
            post.coverImage
              ? post.coverImage.url
              : post.coverVideo
              ? post.coverVideo.url
              : `/image${Math.floor(Math.random() * 6) + 1}.jpg`
          }
          _id={post._id}
        />
      </div>
      <div className="md:grid md:grid-cols-2 md:gap-x-16 lg:gap-x-8 mb-20 md:mb-28">
        <div>
          <h3 className="mb-4 text-4xl lg:text-5xl leading-tight">
            <Link href={`/posts/${post._id}`} className="hover:underline">
              {post.title}
            </Link>
          </h3>
          <div className="mb-4 md:mb-0 text-lg">
            <DateFormatter date={post.date} />
          </div>
        </div>
        <div>
          <p className="text-lg leading-relaxed mb-4">{post.excerpt}</p>
          <Avatar name={post.author} />
        </div>
      </div>
    </section>
  );
}

export default HeroPost;
