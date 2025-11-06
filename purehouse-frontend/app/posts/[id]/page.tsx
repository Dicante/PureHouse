"use client";

import { useEffect, useState } from "react";
import { useParams } from "next/navigation";

import Avatar from "@/app/components/avatar";
import CoverImage from "@/app/components/cover-image";
import DateFormatter from "@/app/components/date-formatter";

import { type Post } from "@/app/interfaces";

const PostPage = () => {
  const params = useParams();
  const id = params.id as string;

  const [post, setPost] = useState<Post | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
  setLoading(true);
  (async () => {
    const { joinApi } = await import('@/app/lib/api');
    try {
      const res = await fetch(joinApi(`/posts/${id}`));
      if (!res.ok) {
        const err = await res.json();
        throw new Error(err.error || "Failed to fetch post");
      }
      const data = await res.json();
      setPost(data);
      setError(null);
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : String(err));
      setPost(null);
    } finally {
      setLoading(false);
    }
  })();
  }, [id]);

  return (
    <>
      {error && <div className="text-red-600 mb-4">{error}</div>}
      {loading && <div className="text-gray-500 mb-4">Loading post...</div>}
      {!post && !loading && <div className="text-gray-500">Post not found</div>}
      {post && (
        <article className="mb-32">
          <h1 className="text-5xl md:text-7xl lg:text-8xl font-bold tracking-tighter leading-tight md:leading-none mb-12 text-center md:text-left">
            {post.title}
          </h1>
          <div className="hidden md:block md:mb-12">
            <Avatar name={post.author} />
          </div>
          <div className="mb-8 md:mb-16 sm:mx-0">
            <CoverImage
              title={post.title}
              src={
                post.coverImage
                  ? post.coverImage.url
                  : post.coverVideo
                  ? post.coverVideo.url
                  : `/image${Math.floor(Math.random() * 6) + 1}.jpg`
              }
            />
          </div>
          <div className="max-w-2xl mx-auto">
            <div className="block md:hidden mb-6">
              <Avatar name={post.author} />
            </div>
            <div className="mb-6 text-lg">
              <DateFormatter date={post.date} />
            </div>
          </div>
          <div className="max-w-2xl mx-auto">
            <div className="text-lg leading-relaxed my-6 whitespace-pre-line mb-12">{post.content}</div>
            <div className="flex flex-col items-center w-full px-10 lg:px-32">
              <a
                href={`/posts/${id}/edit`}
                className="bg-white hover:bg-black hover:text-white border border-black text-black py-1.5 px-12 duration-200 transition-colors font-bold mt-6"
              >
                Edit Post
              </a>
            </div>
          </div>
        </article>
      )}
    </>
  );
};

export default PostPage;
