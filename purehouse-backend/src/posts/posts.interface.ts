import { ObjectId } from 'mongodb';

export interface Post {
  _id?: ObjectId | string;
  title: string;
  author: string;
  content: string;
  excerpt?: string;
  coverImage?: { url: string };
  coverVideo?: { url: string };
  date?: Date | string;
}
