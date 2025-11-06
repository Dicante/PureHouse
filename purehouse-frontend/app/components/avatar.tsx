import Image from "next/image";

const Avatar = ({ name }: { name: string }) => {
  return (
    <div className="flex items-center">
      <Image src="/avatar.jpg" width={48} height={48} className="w-12 h-12 rounded-full mr-4" alt={name} />
      <div className="text-xl font-bold">{name}</div>
    </div>
  );
};

export default Avatar;
