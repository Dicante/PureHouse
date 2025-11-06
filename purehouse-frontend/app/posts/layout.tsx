import Header from "@/app/components/header";
import Container from "@/app/components/container";

export default function PostsLayout({ children }: { children: React.ReactNode }) {
  return (
    <main>
      <Container>
        <Header />
        {children}
      </Container>
    </main>
  );
}
