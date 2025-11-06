"use client";

import { useEffect, useState, useRef } from "react";
import { useRouter, useParams } from "next/navigation";
import { type Post } from "@/app/interfaces";

import Image from "next/image";
import DateFormatter from "@/app/components/date-formatter";
import CoverSelector, { CoverSelectorValue } from "@/app/components/cover-selector";

export default function EditPostPage() {
  const params = useParams();
  const id = params.id as string;
  const [form, setForm] = useState<Partial<Post>>({});
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [coverValue, setCoverValue] = useState<CoverSelectorValue>(null);
  const [summaryExcerpt, setSummaryExcerpt] = useState(true);
  const [showDialog, setShowDialog] = useState(false);
  const router = useRouter();

  const titleRef = useRef<HTMLTextAreaElement>(null) as React.RefObject<HTMLTextAreaElement>;
  const contentRef = useRef<HTMLTextAreaElement>(null) as React.RefObject<HTMLTextAreaElement>;
  const excerptRef = useRef<HTMLTextAreaElement>(null) as React.RefObject<HTMLTextAreaElement>;

  const autoResize = (ref: React.RefObject<HTMLTextAreaElement>) => {
    if (ref.current) {
      ref.current.style.height = "auto";
      ref.current.style.height = ref.current.scrollHeight + "px";
    }
  };

  useEffect(() => {
    if (!summaryExcerpt) {
      autoResize(excerptRef);
    }
  }, [summaryExcerpt]);

  useEffect(() => {
  (async () => {
    const { joinApi } = await import('@/app/lib/api');
    try {
      const res = await fetch(joinApi(`/posts/${id}`));
      if (!res.ok) {
        const err = await res.json();
        throw new Error(err.error || "Failed to fetch post");
      }
      const data = await res.json();
      setForm(data);
      setCoverValue(
        data.coverImage?.url
          ? { type: "image", url: data.coverImage.url }
          : data.coverVideo?.url
          ? { type: "video", url: data.coverVideo.url }
          : null
      );
      setSummaryExcerpt(!data.excerpt || data.excerpt === data.content?.slice(0, 250) + "...");
      setTimeout(() => {
        autoResize(titleRef);
        autoResize(contentRef);
        autoResize(excerptRef);
      }, 50);
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : String(err));
    }
  })();
  }, [id]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    const trimmedStart = value.replace(/^\s+/, "");
    if (name === "title" || name === "author" || name === "content" || name === "excerpt") {
      const capitalized = trimmedStart.length > 0 ? trimmedStart.charAt(0).toUpperCase() + trimmedStart.slice(1) : "";
      setForm({ ...form, [name]: capitalized });
    } else if (name === "coverImage") {
      setForm({ ...form, coverImage: { url: trimmedStart } });
    } else {
      setForm({ ...form, [name]: trimmedStart });
    }
  };

  const handleCoverChange = (val: CoverSelectorValue) => {
    setCoverValue(val);
    if (val?.type === "image") {
      setForm((f) => ({ ...f, coverImage: { url: val.url }, coverVideo: undefined }));
    } else if (val?.type === "video") {
      setForm((f) => ({ ...f, coverVideo: { url: val.url }, coverImage: undefined }));
    } else {
      setForm((f) => ({ ...f, coverImage: undefined, coverVideo: undefined }));
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    const cleanedForm: Partial<Post> = {
      ...form,
      title: form.title?.trim(),
      author: form.author?.trim(),
      content: form.content?.trim(),
      excerpt: summaryExcerpt ? form.content?.slice(0, 250).trim() + "..." : form.excerpt?.trim(),
      coverImage: form.coverImage?.url ? { url: form.coverImage.url.trim() } : undefined,
      coverVideo: form.coverVideo?.url ? { url: form.coverVideo.url.trim() } : undefined,
    };
    try {
    const { joinApi } = await import('@/app/lib/api');
    const res = await fetch(joinApi(`/posts/${id}`), {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(cleanedForm),
      });
      if (!res.ok) {
        const err = await res.json();
        throw new Error(err.error || "Failed to update post");
      }
      router.push("/");
    } catch (err: unknown) {
      if (err instanceof Error) {
        setError(err.message);
      } else {
        setError("An unexpected error occurred");
      }
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async () => {
    setLoading(true);
    setError(null);
    try {
    const { joinApi } = await import('@/app/lib/api');
    const res = await fetch(joinApi(`/posts/${id}`), { method: "DELETE" });
      if (!res.ok) {
        const err = await res.json();
        throw new Error(err.error || "Failed to delete post");
      }
      router.push("/");
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    } finally {
      setLoading(false);
      setShowDialog(false);
    }
  };

  const today = new Date();
  const dateOnly = new Date(today.getFullYear(), today.getMonth(), today.getDate());

  return (
    <form className="mb-32" onSubmit={handleSubmit}>
      <textarea
        ref={titleRef}
        name="title"
        placeholder="Type your post title here"
        value={form.title || ""}
        onChange={handleChange}
        className="resize-none text-5xl md:text-7xl lg:text-8xl font-bold tracking-tighter leading-tight md:leading-none mb-12 md:text-left focus:outline-none placeholder:text-neutral-500 border-none w-full caret-black"
        required
        autoComplete="off"
        maxLength={80}
        onInput={(e) => {
          const target = e.target as HTMLTextAreaElement;
          target.style.height = "auto";
          target.style.height = target.scrollHeight + "px";
        }}
        style={{
          scrollbarWidth: "none",
          msOverflowStyle: "none",
        }}
      />

      <div className="hidden md:block md:mb-12">
        <div className="flex items-center">
          <Image src="/avatar.jpg" width={48} height={48} className="w-12 h-12 rounded-full mr-4" alt="Author Avatar" />
          <input
            type="text"
            name="author"
            placeholder="Type author name here"
            value={form.author || ""}
            onChange={handleChange}
            className="resize-none text-xl font-bold tracking-tighter focus:outline-none placeholder:text-neutral-500 border-none w-full caret-black"
            required
            autoComplete="off"
            maxLength={30}
          />
        </div>
      </div>

      <div className="mb-8 md:mb-16 sm:mx-0">
        <CoverSelector value={coverValue} onChange={handleCoverChange} />
      </div>

      <div className="max-w-2xl mx-auto">
        <div className="block md:hidden mb-6">
          <div className="flex items-center">
            <Image
              src="/avatar.jpg"
              width={48}
              height={48}
              className="w-12 h-12 rounded-full mr-4"
              alt="Author Avatar"
            />
            <input
              type="text"
              name="author"
              placeholder="Type author name here"
              value={form.author || ""}
              onChange={handleChange}
              className="resize-none text-xl font-bold tracking-tighter focus:outline-none placeholder:text-neutral-500 border-none w-full caret-black"
              required
              autoComplete="off"
              maxLength={30}
            />
          </div>
        </div>
        <div className="mb-6 text-lg">
          <DateFormatter date={dateOnly} />
        </div>
      </div>

      <div className="max-w-2xl mx-auto">
        <textarea
          ref={contentRef}
          name="content"
          placeholder="Type your post content here"
          value={form.content || ""}
          onChange={handleChange}
          className="resize-none text-lg mb-12 md:text-left focus:outline-none placeholder:text-neutral-500 border-none w-full caret-black"
          required
          autoComplete="off"
          maxLength={10000}
          onInput={(e) => {
            const target = e.target as HTMLTextAreaElement;
            target.style.height = "auto";
            target.style.height = target.scrollHeight + "px";
          }}
          style={{
            scrollbarWidth: "none",
            msOverflowStyle: "none",
          }}
        />

        {/* checkbox for summary excerpt */}
        <label className="flex items-center mb-6 cursor-pointer select-none gap-2">
          <input
            type="checkbox"
            checked={summaryExcerpt}
            onChange={(e) => setSummaryExcerpt(e.target.checked)}
            className="absolute opacity-0 w-5 h-5 peer"
            tabIndex={0}
          />
          <span className="relative w-5 h-5 flex items-center justify-center border border-black bg-white peer-checked:bg-black transition-colors duration-100 rounded-none">
            <svg
              className="w-4 h-4 pointer-events-none -translate-x-1/12 translate-y-[-5%]"
              viewBox="0 0 20 20"
              fill="none"
              stroke="white"
              strokeWidth="2"
            >
              <path d="M5 10.5L9 15L18 6" />
            </svg>
          </span>
          <span className="ml-1.5">Use summary excerpt</span>
        </label>

        {summaryExcerpt && <div className="text-lg text-neutral-500 mb-12">{form.content?.slice(0, 250)}...</div>}

        {!summaryExcerpt && (
          <textarea
            ref={excerptRef}
            name="excerpt"
            placeholder="Type your post excerpt here"
            value={form.excerpt || ""}
            onChange={handleChange}
            className="resize-none text-lg mb-12 md:text-left focus:outline-none placeholder:text-neutral-500 border-none w-full caret-black"
            required
            autoComplete="off"
            maxLength={250}
            onInput={(e) => {
              const target = e.target as HTMLTextAreaElement;
              target.style.height = "auto";
              target.style.height = target.scrollHeight + "px";
            }}
            style={{
              scrollbarWidth: "none",
              msOverflowStyle: "none",
            }}
          />
        )}

        {error && <div className="text-red-600 mb-6">{error}</div>}

        <div className="flex flex-col items-center w-full px-10 lg:px-32">
          <button
            type="submit"
            className="bg-black hover:bg-white hover:text-black border border-black text-white font-bold py-2 duration-200 transition-colors w-full mb-6 lg:mb-0"
            disabled={loading}
          >
            {loading ? "Saving..." : "Save"}
          </button>
          <button
            type="button"
            className="text-red-600 font-bold py-2 duration-200 transition-colors w-full mt-2 hover:underline"
            onClick={() => setShowDialog(true)}
            disabled={loading}
          >
            Delete
          </button>
        </div>
      </div>
      {showDialog && (
        <div className="fixed inset-0 flex items-center justify-center bg-black/25 z-50">
          <div className="bg-white p-6 mx-8 shadow-lg">
            <p className="mb-4">Are you sure you want to delete this post?</p>
            <div className="flex flex-row gap-3">
              <button
                className="bg-white hover:bg-black hover:text-white border border-black text-black font-bold py-2 duration-200 transition-colors w-full"
                onClick={handleDelete}
                disabled={loading}
              >
                Yes, Delete
              </button>
              <button
                className="bg-black hover:bg-white hover:text-black border border-black text-white font-bold py-2 duration-200 transition-colors w-full"
                onClick={() => setShowDialog(false)}
                disabled={loading}
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </form>
  );
}
