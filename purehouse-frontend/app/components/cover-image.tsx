import Link from "next/link";

// Detectores simples
function isYouTubeUrl(url: string) {
  return /^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\//.test(url);
}
// eslint-disable-next-line @typescript-eslint/no-unused-vars
function isImageUrl(url: string) {
  return /\.(jpeg|jpg|gif|png|webp|bmp|svg)$/i.test(url.split('?')[0]);
}
function isVideoUrl(url: string) {
  return /\.(mp4|webm|ogg|mov|avi|mkv)$/i.test(url.split('?')[0]);
}

// El src puede ser imagen, video o YouTube

type Props = {
  title: string;
  src: string;
  _id?: string;
};

const CoverImage = ({ title, src, _id }: Props) => {
  let media;
  if (isYouTubeUrl(src)) {
    media = (
      <iframe
        src={src}
        title={title}
        className="shadow-sm w-full aspect-video"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowFullScreen
      />
    );
  } else if (isVideoUrl(src)) {
    media = (
      <video
        src={src}
        className="shadow-sm w-full aspect-video"
        controls
        autoPlay
        loop
        muted
        title={title}
      />
    );
  } else {
    media = (
      // eslint-disable-next-line @next/next/no-img-element
      <img
        src={src}
        alt={`Cover Image for ${title}`}
        className={`shadow-sm w-full aspect-video ${_id ? "hover:shadow-lg transition-shadow duration-200" : ""}`}
        width={1300}
        height={630}
      />
    );
  }
  return (
    <div className="sm:mx-0">
      {_id ? (
        <Link href={`/posts/${_id}`} aria-label={title}>
          {media}
        </Link>
      ) : (
        media
      )}
    </div>
  );
};

export default CoverImage;
