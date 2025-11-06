import { Inject, Injectable, NotFoundException, Logger } from '@nestjs/common';
import {
  Collection,
  Db,
  MongoClient,
  ObjectId,
  Filter,
  OptionalId,
  InsertOneResult,
  UpdateResult,
  DeleteResult,
} from 'mongodb';
import { MONGO_CLIENT } from '../mongo.provider';
import { Post } from './posts.interface';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';

@Injectable()
export class PostsService {
  private collectionName = 'posts';
  private readonly logger = new Logger(PostsService.name);
  private readonly workerUrl = process.env.WORKER_URL ?? '';

  constructor(@Inject(MONGO_CLIENT) private readonly client: MongoClient) {}

  private getCollection(): Collection<Post> {
    const dbName =
      process.env.MONGODB_DB ?? process.env.MONGO_DB ?? 'purehouse';
    const db: Db = this.client.db(dbName);
    return db.collection<Post>(this.collectionName);
  }

  async findAll(): Promise<Post[]> {
    return this.getCollection().find({}).toArray();
  }

  async findOne(id: string): Promise<Post> {
    const filter: Filter<Post> = {
      _id: new ObjectId(id),
    } as unknown as Filter<Post>;
    const doc = await this.getCollection().findOne(filter);
    if (!doc) throw new NotFoundException('Post not found');
    return doc;
  }

  async create(createPostDto: CreatePostDto) {
    const cleaned = {
      ...createPostDto,
      title: createPostDto.title?.trim(),
      author: createPostDto.author?.trim(),
      content: createPostDto.content?.trim(),
      excerpt: createPostDto.excerpt?.trim(),
      coverImage: createPostDto.coverImage?.url
        ? { url: createPostDto.coverImage.url.trim() }
        : undefined,
      coverVideo: createPostDto.coverVideo?.url
        ? { url: createPostDto.coverVideo.url.trim() }
        : undefined,
      date: new Date(),
    };
    const cleanedDoc: OptionalId<Post> = cleaned as OptionalId<Post>;
    const result: InsertOneResult<Post> =
      await this.getCollection().insertOne(cleanedDoc);
    const insertedId = result.insertedId;
    // Notify worker (best-effort)
    void this.notifyWorker({
      level: 'SUCCESS',
      message: 'Post created successfully',
      metadata: {
        event: 'post.created',
        id: insertedId.toString(),
        title: cleaned.title,
      },
    });
    return { insertedId };
  }

  async update(id: string, updatePostDto: UpdatePostDto) {
    const payload: Partial<Post> = { ...updatePostDto };
    delete payload._id;
    const filter: Filter<Post> = {
      _id: new ObjectId(id),
    } as unknown as Filter<Post>;
    const result: UpdateResult = await this.getCollection().updateOne(filter, {
      $set: payload,
    });
    if (result.matchedCount === 0)
      throw new NotFoundException('Post not found');
    void this.notifyWorker({
      level: 'INFO',
      message: 'Post updated successfully',
      metadata: {
        event: 'post.updated',
        id,
        changes: updatePostDto,
      },
    });
    return { modifiedCount: result.modifiedCount };
  }

  async remove(id: string) {
    const filter: Filter<Post> = {
      _id: new ObjectId(id),
    } as unknown as Filter<Post>;
    const result: DeleteResult = await this.getCollection().deleteOne(filter);
    if (result.deletedCount === 0)
      throw new NotFoundException('Post not found');
    void this.notifyWorker({
      level: 'WARN',
      message: 'Post deleted',
      metadata: {
        event: 'post.deleted',
        id,
      },
    });
    return { deletedCount: result.deletedCount };
  }

  private async notifyWorker(payload: Record<string, unknown>) {
    if (!this.workerUrl) return;
    try {
      // Node 18+ has global fetch; otherwise this will throw and we ignore it (best-effort)
      await fetch(this.workerUrl.replace(/\/+$/, '') + '/logs', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
    } catch (err) {
      const e = err as unknown;
      this.logger.warn(
        'Failed to notify worker: ' +
          (e instanceof Error ? e.message : String(e)),
      );
    }
  }
}
