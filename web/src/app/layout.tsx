import type { Metadata } from "next";
import { Sora } from "next/font/google";
import "./globals.css";

const sora = Sora({
  subsets: ["latin"],
  variable: "--font-sora",
  weight: ["300", "400", "500", "600", "700", "800"],
  display: "swap",
});

export const metadata: Metadata = {
  metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL || "https://tkmingle.vercel.app"),
  title: "TKMingle — Campus Social Discovery Platform | TKMCE",
  description:
    "Private campus social discovery platform exclusively for TKM College of Engineering (TKMCE), Kollam. Your campus. Your people. Your connections.",
  icons: {
    icon: "/images/app_icon.png",
    apple: "/images/app_icon.png",
  },
  openGraph: {
    title: "TKMingle — Your campus. Your people. Your connections.",
    description: "Discover verified students, join campus circles, and build meaningful college connections across departments at TKMCE.",
    url: "https://tkmingle.vercel.app",
    siteName: "TKMingle",
    images: [
      {
        url: "/images/brand_banner_crop.png",
        width: 1200,
        height: 630,
        alt: "TKMingle Brand",
      },
    ],
    type: "website",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={`dark ${sora.variable}`}>
      <body className="min-h-screen bg-brand-navy text-brand-text antialiased selection:bg-brand-purple selection:text-white">
        {children}
      </body>
    </html>
  );
}
