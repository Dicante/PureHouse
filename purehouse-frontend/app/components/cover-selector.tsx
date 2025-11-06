import { useState, useRef } from "react";

export type CoverSelectorValue =
  | { type: "image"; url: string }
  | { type: "video"; url: string }
  | null;

export default function CoverSelector({
  value,
  onChange,
}: {
  value: CoverSelectorValue;
  onChange: (val: CoverSelectorValue) => void;
}) {
  const [coverInput, setCoverInput] = useState("");
  const [coverError, setCoverError] = useState<string | null>(null);
  const imageRef = useRef<HTMLImageElement>(null);

  // Detect if URL is YouTube
  function isYouTubeUrl(url: string) {
    return /^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\//.test(url);
  }
  function getYouTubeEmbed(url: string) {
    const match = url.match(/(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=))([\w-]{11})/);
    return match ? `https://www.youtube.com/embed/${match[1]}` : null;
  }
  // Detect if URL is image
  function isImageUrl(url: string) {
    return /\.(jpeg|jpg|gif|png|webp|bmp|svg)$/i.test(url.split('?')[0]);
  }
  // Detect if URL is video (not YouTube)
  function isVideoUrl(url: string) {
    return /\.(mp4|webm|ogg|mov|avi|mkv)$/i.test(url.split('?')[0]);
  }

  const handleCoverInput = (e: React.ChangeEvent<HTMLInputElement>) => {
    setCoverInput(e.target.value);
    setCoverError(null);
  };

  const handleCoverBlur = () => {
    setCoverError(null);
    const url = coverInput.trim();
    if (!url) return;
    // YouTube
    if (isYouTubeUrl(url)) {
      const embed = getYouTubeEmbed(url);
      if (embed) {
        onChange({ type: "video", url: embed });
      } else {
        setCoverError("Invalid YouTube URL.");
      }
      return;
    }
    // Image
    if (isImageUrl(url)) {
      const img = new window.Image();
      img.onload = () => {
        setCoverError(null);
        onChange({ type: "image", url });
      };
      img.onerror = () => setCoverError("Could not load the image.");
      img.src = url;
      return;
    }
    // Video
    if (isVideoUrl(url)) {
      const video = document.createElement("video");
      video.onloadeddata = () => {
        onChange({ type: "video", url });
      };
      video.onerror = () => setCoverError("Could not load the video.");
      video.src = url;
      return;
    }
    setCoverError("URL is not a supported image or video format.");
  };

  const handleRemoveCover = () => {
    onChange(null);
    setCoverInput("");
    setCoverError(null);
  };

  return (
    <div
      className="shadow-sm w-full aspect-video bg-cover bg-center relative overflow-hidden"
      style={{ backgroundImage: "url('/image6.jpg')" }}
    >
      {/* Input only, no buttons */}
      {!value && (
        <div className="w-full h-full flex flex-col items-center justify-center bg-white/75 gap-2">
          <input
            type="text"
            name="coverUrl"
            placeholder="Paste video or image URL"
            value={coverInput}
            onChange={handleCoverInput}
            onBlur={handleCoverBlur}
            className="resize-none text-base lg:text-lg tracking-tighter focus:outline-none placeholder:text-neutral-500 border border-black caret-black px-4 text-center w-2/3"
            autoComplete="off"
          />
          {coverError && <div className="text-red-600 text-sm  mt-1 absolute translate-y-8">{coverError}</div>}
        </div>
      )}
      {/* Preview image or video */}
      {value && (
        <>
          {value.type === "image" && !coverError ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              ref={imageRef}
              src={value.url}
              alt="Cover Preview"
              className="absolute inset-0 w-full h-full object-cover"
              onError={() => {
                setCoverError("Could not load the image.");
                setTimeout(() => onChange(null), 0);
              }}
            />
          ) : value.type === "image" && coverError ? null : isYouTubeUrl(value.url) ? (
            <iframe
              src={value.url}
              className="absolute inset-0 w-full h-full object-cover"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowFullScreen
              title="YouTube video preview"
            />
          ) : (
            <video
              src={value.url}
              className="absolute inset-0 w-full h-full object-cover"
              controls
              autoPlay
              loop
              muted
              onError={() => {
                setCoverError("Could not load the video.");
                setTimeout(() => onChange(null), 0);
              }}
            />
          )}
          <button
            type="button"
            className="absolute bottom-12 lg:bottom-2 right-2 bg-black aspect-square p-2 text-white hover:bg-white hover:text-black flex"
            onClick={handleRemoveCover}
            aria-label="Remove cover"
          >
            <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeWidth={1} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
          {coverError && (
            <div className="absolute bottom-2 left-2 text-red-600 text-sm bg-white/80 px-2 py-1">
              {coverError}
            </div>
          )}
        </>
      )}
    </div>
  );
}
