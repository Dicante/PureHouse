export type Post = {
  _id?: string;
  title: string;
  date: Date | string;
  coverImage?: {
    url: string;
  };
  coverVideo?: {
    url: string;
  };
  author: string;
  excerpt: string;
  content: string;
};
