"use client";

import { useEffect, useState } from "react";

import { type Post } from "./interfaces";

import Container from "./components/container";
import Intro from "./components/intro";
import HeroPost from "./components/hero-post";
import PostPreview from "./components/post-preview";

export default function HomePage() {
  const [posts, setPosts] = useState<Post[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
  setLoading(true);
  (async () => {
    const { joinApi } = await import('./lib/api');
    try {
      const res = await fetch(joinApi('/posts'));
      if (!res.ok) {
        const err = await res.json();
        throw new Error(err.error || "Failed to fetch posts");
      }
      const data = await res.json();
      setPosts(data.reverse());
      setError(null);
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : String(err));
      setPosts([]);
    } finally {
      setLoading(false);
    }
  })();
  }, []);

  // Place your custom 'no posts found' or error message here:
  // if (error) return <div>{error}</div>;
  // if (!loading && posts.length === 0) return <div>No posts found</div>;

  return (
    <main>
      <Container>
        <Intro />
        {(error || loading || (posts.length === 0 && !loading)) && (
          <div className="flex items-center justify-center min-h-[40vh]">
            {error && <div className="text-red-600 mb-4 text-center">{error}</div>}
            {loading && <div className="mb-4 text-center">Loading posts...</div>}
            {posts.length === 0 && !loading && <div className="text-center mb-4">No posts found</div>}
          </div>
        )}
        {posts.length > 0 && <HeroPost post={posts[0]} />}
        {posts.length > 1 && (
          <section>
            <h2 className="mb-8 text-5xl md:text-7xl font-bold tracking-tighter leading-tight">More Posts</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 md:gap-x-16 lg:gap-x-32 gap-y-20 md:gap-y-32 mb-32">
              {posts.slice(1).map((post) => (
                <PostPreview key={post._id} post={post} />
              ))}
            </div>
          </section>
        )}
      </Container>
    </main>
  );
}
