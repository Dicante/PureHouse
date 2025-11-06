import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

import Footer from "./components/footer";

const geistInter = Inter({
  variable: "--font-Inter",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Pure House",
  description: "This is a simple web app for my cloud computing course.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${geistInter.variable} antialiased`}>
        <div className="min-h-screen">{children}</div>
        <Footer />
      </body>
    </html>
  );
}
