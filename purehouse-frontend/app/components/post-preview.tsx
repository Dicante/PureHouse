import Link from "next/link";
import Avatar from "./avatar";
import CoverImage from "./cover-image";
import DateFormatter from "./date-formatter";
import { type Post } from "@/app/interfaces";

function PostPreview({ post }: { post: Post }) {
  return (
    <div>
      <div className="mb-5">
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
      <h3 className="text-3xl mb-3 leading-snug">
        <Link href={`/posts/${post._id}`} className="hover:underline">
          {post.title}
        </Link>
      </h3>
      <div className="text-lg mb-4">
        <DateFormatter date={post.date} />
      </div>
      <p className="text-lg leading-relaxed mb-4">{post.excerpt}</p>
      <Avatar name={post.author} />
    </div>
  );
}

export default PostPreview;
