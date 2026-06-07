import type { Metadata, Viewport } from "next";
import "./globals.css";

export const metadata: Metadata = {
  metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL ?? "https://himanm.github.io/BrokenOps"),
  title: {
    default: "BrokenOps | Community Linux Lab Platform",
    template: "%s | BrokenOps",
  },
  description:
    "Community-driven Linux lab platform for local troubleshooting, merged lab releases, and hands-on system repair.",
  keywords: [
    "BrokenOps",
    "Linux labs",
    "KVM",
    "libvirt",
    "community project",
    "sysadmin training",
  ],
  authors: [{ name: "HimanM", url: "https://github.com/HimanM" }],
  creator: "HimanM",
  applicationName: "BrokenOps",
  icons: {
    icon: [
      { url: "favicon.svg", type: "image/svg+xml" },
      { url: "icon.svg", type: "image/svg+xml" },
    ],
    apple: "apple-icon.svg",
  },
  openGraph: {
    type: "website",
    title: "BrokenOps | Community Linux Lab Platform",
    description:
      "Community-driven labs for Linux users, setup guidance, recently merged labs, and contributor profiles.",
    url: ".",
    siteName: "BrokenOps",
    images: [
      {
        url: "opengraph-image.svg",
        width: 1200,
        height: 630,
        alt: "BrokenOps",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "BrokenOps | Community Linux Lab Platform",
    description:
      "Community-driven labs for Linux users, setup guidance, recently merged labs, and contributor profiles.",
    images: ["opengraph-image.svg"],
  },
};

export const viewport: Viewport = {
  themeColor: "#050608",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        <div className="bg-container">
          <div className="bg-aurora" />
          <div className="bg-beams" />
          <div className="bg-grid" />
        </div>
        <nav className="navbar">
          <div className="navbar-logo">BROKENOPS</div>
          <div className="navbar-links">
            <a href="#overview">OVERVIEW</a>
            <a href="#setup">SETUP</a>
            <a href="#labs">LABS</a>
            <a href="#contribute">CONTRIBUTE</a>
          </div>
        </nav>
        {children}
        <footer style={{ 
          padding: '4rem 1.5rem', 
          borderTop: '1px solid var(--card-border)',
          textAlign: 'center',
          color: 'var(--dimmed)',
          fontSize: '0.875rem',
          position: 'relative',
          background: 'rgba(3,3,3,0.8)',
          zIndex: 10
        }}>
          <p>BrokenOps &copy; 2026. Built by HimanM.</p>
          <div style={{ marginTop: '1rem', display: 'flex', justifyContent: 'center', gap: '1.5rem' }}>
            <a href="https://github.com/HimanM/BrokenOps">GitHub</a>
            <a href="https://www.linkedin.com/in/himanm/">LinkedIn</a>
          </div>
        </footer>
      </body>
    </html>
  );
}
