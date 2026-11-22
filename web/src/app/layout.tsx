import type { Metadata, Viewport } from "next";
import { Sora } from "next/font/google";
import AuthRedirectHandler from "@/components/AuthRedirectHandler";
import PwaRegister from "@/components/PwaRegister";
import "./globals.css";

const sora = Sora({
  subsets: ["latin"],
  variable: "--font-sora",
  weight: ["300", "400", "500", "600", "700", "800"],
  display: "swap",
});

export const viewport: Viewport = {
  themeColor: "#0B0E17",
  width: "device-width",
  initialScale: 1,
  maximumScale: 5,
};

export const metadata: Metadata = {
  metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL || "https://tkmingle.vercel.app"),
  title: "TKMingle — Campus Social Discovery Platform | TKMCE",
  description:
    "Private campus social discovery platform exclusively for TKM College of Engineering (TKMCE), Kollam. Your campus. Your people. Your connections.",
  applicationName: "TKMingle",
  manifest: "/manifest.webmanifest",
  icons: {
    icon: [
      { url: "/favicon.ico", sizes: "any" },
      { url: "/icons/icon-192x192.png", sizes: "192x192", type: "image/png" },
      { url: "/icons/icon-512x512.png", sizes: "512x512", type: "image/png" },
    ],
    apple: [
      { url: "/apple-touch-icon.png", sizes: "180x180", type: "image/png" },
      { url: "/apple-touch-icon-precomposed.png", sizes: "180x180", type: "image/png" },
    ],
  },
  appleWebApp: {
    capable: true,
    statusBarStyle: "black-translucent",
    title: "TKMingle",
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
      <head>
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
        <meta name="apple-mobile-web-app-title" content="TKMingle" />
        <meta name="mobile-web-app-capable" content="yes" />
        <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
      </head>
      <body className="min-h-screen bg-brand-navy text-brand-text antialiased selection:bg-brand-purple selection:text-white">
        <AuthRedirectHandler />
        <PwaRegister />
        {children}
      </body>
    </html>
  );
}
