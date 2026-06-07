'use client';

import Image from 'next/image';
import { useEffect, useState } from 'react';
import siteData from '@/generated/site-data.json';
import { fetchContributors, fetchLatestRelease, Contributor, ReleaseInfo } from '@/lib/github';

function previewMarkdown(text: string): string {
  return (text || '')
    .replace(/^#{1,6}\s+/gm, '')
    .replace(/^\s*[-*+]\s+/gm, 'â€¢ ')
    .replace(/`([^`]+)`/g, '$1')
    .replace(/\[(.*?)\]\((.*?)\)/g, '$1')
    .replace(/\*\*(.*?)\*\*/g, '$1')
    .replace(/\*(.*?)\*/g, '$1')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}

export default function Home() {
  const [contributors, setContributors] = useState<Contributor[]>([]);
  const [latestRelease, setLatestRelease] = useState<ReleaseInfo | null>(null);

  useEffect(() => {
    async function loadData() {
      try {
        setContributors(await fetchContributors());
        setLatestRelease(await fetchLatestRelease());
      } catch (e) {
        console.error("Failed to load data", e);
      }
    }
    loadData();
  }, []);

  // Filter out invalid contributors
  const filteredContributors = contributors.filter(c => 
    c.login && c.login !== 'HimanM' && c.avatar_url
  );
  const labs = siteData.labs;

  return (
    <main>
      {/* Hero Section */}
      <section className="hero-full" style={{ textAlign: 'center' }}>
        <h1 style={{ fontSize: 'clamp(3rem, 10vw, 5rem)', marginBottom: '1.5rem', lineHeight: 1.1 }}>BrokenOps</h1>
        <p style={{ 
          fontSize: '1.25rem', 
          maxWidth: '600px', 
          color: 'var(--dimmed)', 
          marginBottom: '2.5rem',
          lineHeight: 1.6
        }}>
          A community-driven Linux lab platform. 
          Master local troubleshooting by breaking, fixing, and verifying real systems.
        </p>
        <div style={{ display: 'flex', gap: '1rem', justifyContent: 'center' }}>
          <a href="#setup" className="button">Read Setup</a>
          <a href="#labs" className="button secondary">See Labs</a>
        </div>
        
        <div className="hero-grid" style={{ 
          marginTop: '5rem', 
          display: 'grid', 
          gridTemplateColumns: 'repeat(3, 1fr)', 
          gap: '2rem',
          width: '100%',
          maxWidth: '900px'
        }}>
          <div className="card">
            <h3 style={{ fontSize: '0.75rem', color: 'var(--accent)', fontFamily: 'var(--mono-font)', marginBottom: '0.5rem', letterSpacing: '0.1em' }}>01. NATIVE</h3>
            <p style={{ fontSize: '0.75rem', color: 'var(--dimmed)' }}>Runs directly on your hardware for realism.</p>
          </div>
          <div className="card">
            <h3 style={{ fontSize: '0.75rem', color: 'var(--accent)', fontFamily: 'var(--mono-font)', marginBottom: '0.5rem', letterSpacing: '0.1em' }}>02. KVM</h3>
            <p style={{ fontSize: '0.75rem', color: 'var(--dimmed)' }}>Standard virtualization for lab isolation.</p>
          </div>
          <div className="card">
            <h3 style={{ fontSize: '0.75rem', color: 'var(--accent)', fontFamily: 'var(--mono-font)', marginBottom: '0.5rem', letterSpacing: '0.1em' }}>03. OPEN</h3>
            <p style={{ fontSize: '0.75rem', color: 'var(--dimmed)' }}>Driven by practitioners and real scenarios.</p>
          </div>
        </div>

        <a href="#overview" className="scroll-indicator">
          SCROLL TO EXPLORE â†“
        </a>
      </section>

      {/* Overview */}
      <section id="overview" style={{ borderTop: '1px solid var(--card-border)' }}>
        <div className="overview-grid" style={{ display: 'grid', gridTemplateColumns: '1fr 1.5fr', gap: '4rem' }}>
          <div>
            <h2 style={{ fontSize: '2.5rem', marginBottom: '1rem' }}>Local-First Troubleshooting</h2>
            <p style={{ color: 'var(--accent)', fontFamily: 'var(--mono-font)', fontSize: '0.8rem', letterSpacing: '0.1em' }}>THE BROKENOPS PHILOSOPHY</p>
          </div>
          <div style={{ fontSize: '1.125rem', lineHeight: 1.8, color: 'var(--dimmed)' }}>
            <p style={{ marginBottom: '1.5rem' }}>
              BrokenOps isn&apos;t another cloud-based sandbox. It&apos;s a collection of intentionally broken local environments designed to teach you how Linux systems fail and how to fix them.
            </p>
            <p>
              By focusing on local Linux installations with KVM/libvirt, we ensure that you&apos;re learning skills that translate directly to production environments.
            </p>
          </div>
        </div>
      </section>

      {/* Latest Release */}
      <section id="release" style={{ borderTop: '1px solid var(--card-border)' }}>
        <div className="release-callout" style={{ 
          display: 'grid', 
          gridTemplateColumns: 'minmax(0, 1fr) auto', 
          gap: '2rem', 
          alignItems: 'center' 
        }}>
          <div>
            <p style={{ fontFamily: 'var(--mono-font)', color: 'var(--accent)', fontSize: '0.75rem', letterSpacing: '0.15em', marginBottom: '0.75rem' }}>
              LATEST RELEASE
            </p>
            <h2 style={{ fontSize: '2.5rem', marginBottom: '1rem' }}>
              {latestRelease ? (latestRelease.name || latestRelease.tag_name) : 'No release loaded yet'}
            </h2>
            <p style={{ color: 'var(--dimmed)', fontSize: '1rem', lineHeight: 1.8, maxWidth: '72ch', whiteSpace: 'pre-line' }}>
              {latestRelease
                ? previewMarkdown(latestRelease.body) || 'A recent BrokenOps release from GitHub.'
                : 'The homepage reads the GitHub Releases API and shows the newest published prerelease or normal release.'}
            </p>
          </div>
          <div style={{ textAlign: 'right' }}>
            <span style={{ 
              display: 'inline-block',
              padding: '0.35rem 0.75rem',
              borderRadius: '999px',
              border: '1px solid var(--card-border)',
              color: 'var(--accent)',
              fontFamily: 'var(--mono-font)',
              fontSize: '0.7rem',
              letterSpacing: '0.12em',
              marginBottom: '1rem'
            }}>
              {latestRelease?.prerelease ? 'PRE-RELEASE' : 'RELEASE'}
            </span>
            <p style={{ color: 'var(--dimmed)', fontSize: '0.85rem', marginBottom: '1rem' }}>
              {latestRelease ? new Date(latestRelease.published_at || latestRelease.created_at).toLocaleDateString() : 'Waiting for release data'}
            </p>
            <a
              href={latestRelease?.html_url || 'https://github.com/HimanM/BrokenOps/releases'}
              target="_blank"
              rel="noopener noreferrer"
              className="button"
            >
              Open release
            </a>
          </div>
        </div>
      </section>

      {/* Setup */}
      <section id="setup" className="setup-full" style={{ background: '#000', borderTop: '1px solid var(--card-border)', borderBottom: '1px solid var(--card-border)' }}>
        <div className="setup-container" style={{ width: '100%', maxWidth: 'none' }}>
          <h2 style={{ fontSize: '2.5rem', marginBottom: '3rem', textAlign: 'center' }}>Getting Started</h2>
          <div style={{ marginBottom: '2.5rem' }}>
            <h3 style={{ marginBottom: '1rem', fontFamily: 'var(--mono-font)', fontSize: '0.9rem', color: 'var(--accent)' }}>1. CLONE THE REPOSITORY</h3>
            <pre style={{ padding: '1.5rem', background: '#000', border: '1px solid #1a1a1a', overflowX: 'auto', borderRadius: '4px' }}>
              <code>git clone https://github.com/HimanM/BrokenOps.git{"\n"}cd BrokenOps</code>
            </pre>
          </div>
          <div style={{ marginBottom: '2.5rem' }}>
            <h3 style={{ marginBottom: '1rem', fontFamily: 'var(--mono-font)', fontSize: '0.9rem', color: 'var(--accent)' }}>2. INSTALL HOST PREREQUISITES</h3>
            <pre style={{ padding: '1.5rem', background: '#000', border: '1px solid #1a1a1a', overflowX: 'auto', borderRadius: '4px' }}>
              <code># install KVM, libvirt, dnsmasq, and Docker with your distro package manager{"\n"}# then make sure libvirtd is running and the default network is active{"\n"}sudo systemctl enable --now libvirtd{"\n"}sudo virsh net-start default{"\n"}sudo virsh net-autostart default</code>
            </pre>
          </div>
          <div style={{ marginBottom: '2.5rem' }}>
            <h3 style={{ marginBottom: '1rem', fontFamily: 'var(--mono-font)', fontSize: '0.9rem', color: 'var(--accent)' }}>3. DEPLOY A LAB</h3>
            <pre style={{ padding: '1.5rem', background: '#000', border: '1px solid #1a1a1a', overflowX: 'auto', borderRadius: '4px' }}>
              <code>./deploy.sh{"\n"}# choose a lab from the dashboard</code>
            </pre>
          </div>
          <div style={{ width: '100%', marginTop: '2rem', border: '1px solid rgba(212,175,55,0.28)', background: '#0a0a0a', borderRadius: '6px', padding: '1.5rem 1.75rem', textAlign: 'center' }}>
            <p style={{ color: '#f1e2b0', fontSize: '1.02rem', lineHeight: 1.8, margin: 0, fontWeight: 500 }}>
              {'BrokenOps requires a native Linux host with KVM and libvirt available locally. WSL2, Docker Desktop virtualization, and nested virtualization are not supported.'}
            </p>
          </div>
        </div>
      </section>

      {/* Labs */}
      <section id="labs">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', marginBottom: '4rem' }}>
          <div>
            <h2 style={{ fontSize: '2.5rem', marginBottom: '0.5rem' }}>Recent Labs</h2>
            <p style={{ fontFamily: 'var(--mono-font)', color: 'var(--accent)', fontSize: '0.75rem', letterSpacing: '0.1em' }}>LATEST COMMITS IN THE LABS TREE</p>
          </div>
        </div>
        <div className="grid-container" style={{ 
          display: 'grid', 
          gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', 
          gap: '1.5rem' 
        }}>
          {labs.map(lab => (
            <a key={lab.id} href={lab.url} target="_blank" rel="noopener noreferrer" className="card">
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1.5rem', gap: '1rem' }}>
                <span style={{ fontSize: '0.65rem', color: 'var(--accent)', fontFamily: 'var(--mono-font)', background: 'rgba(212,175,55,0.1)', padding: '2px 8px', borderRadius: '10px' }}>
                  {String(lab.category || 'general').toUpperCase()}
                </span>
                <span style={{ fontSize: '0.65rem', color: 'var(--dimmed)', fontFamily: 'var(--mono-font)' }}>
                  {new Date(lab.updatedAt).toLocaleDateString()}
                </span>
              </div>
              <h3 style={{ marginBottom: '1rem', fontSize: '1.25rem' }}>{lab.title}</h3>
              <p style={{ 
                fontSize: '0.875rem', 
                color: 'var(--dimmed)', 
                lineHeight: 1.6,
                display: '-webkit-box',
                WebkitLineClamp: 3,
                WebkitBoxOrient: 'vertical',
                overflow: 'hidden',
                whiteSpace: 'pre-line'
              }}>
                {lab.summary || 'New lab scenario added to BrokenOps.'}
              </p>
              <div style={{ marginTop: '1rem', display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
                <span style={{ fontSize: '0.65rem', color: 'var(--dimmed)', fontFamily: 'var(--mono-font)', border: '1px solid var(--card-border)', padding: '2px 8px', borderRadius: '999px' }}>
                  {String(lab.difficulty || 'unknown').toUpperCase()}
                </span>
                {lab.labId ? (
                  <span style={{ fontSize: '0.65rem', color: 'var(--dimmed)', fontFamily: 'var(--mono-font)', border: '1px solid var(--card-border)', padding: '2px 8px', borderRadius: '999px' }}>
                    {lab.labId}
                  </span>
                ) : null}
              </div>
            </a>
          ))}
        </div>
      </section>

      {/* Contribute */}
      <section id="contribute" style={{ borderTop: '1px solid var(--card-border)' }}>
        <div style={{ textAlign: 'center', maxWidth: '800px', margin: '0 auto' }}>
          <h2 style={{ fontSize: '2.5rem', marginBottom: '1.5rem' }}>Join the Project</h2>
          <p style={{ fontSize: '1.125rem', color: 'var(--dimmed)', marginBottom: '4rem' }}>
            Whether it&apos;s a new lab scenario, a fix for a bug, or documentation updates, your help is welcome.
          </p>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '2rem', textAlign: 'left' }} className="overview-grid">
            <div className="card">
              <h4 style={{ color: 'var(--accent)', marginBottom: '0.75rem', fontSize: '0.8rem', fontFamily: 'var(--mono-font)' }}>ADD A LAB</h4>
              <p style={{ fontSize: '0.8rem', color: 'var(--dimmed)', lineHeight: 1.5 }}>Share a troubleshooting scenario you&apos;ve encountered.</p>
            </div>
            <div className="card">
              <h4 style={{ color: 'var(--accent)', marginBottom: '0.75rem', fontSize: '0.8rem', fontFamily: 'var(--mono-font)' }}>REVISE DOCS</h4>
              <p style={{ fontSize: '0.8rem', color: 'var(--dimmed)', lineHeight: 1.5 }}>Help make our guides clearer for new users.</p>
            </div>
            <div className="card">
              <h4 style={{ color: 'var(--accent)', marginBottom: '0.75rem', fontSize: '0.8rem', fontFamily: 'var(--mono-font)' }}>REVIEW PRS</h4>
              <p style={{ fontSize: '0.8rem', color: 'var(--dimmed)', lineHeight: 1.5 }}>Join the discussion and help maintain quality.</p>
            </div>
          </div>
          <a href="https://github.com/HimanM/BrokenOps" className="button" style={{ marginTop: '4rem' }}>OPEN REPOSITORY</a>
        </div>
      </section>

      {/* Contributors */}
      <section id="contributors" style={{ borderTop: '1px solid var(--card-border)' }}>
        <h2 style={{ fontSize: '2rem', marginBottom: '4rem', textAlign: 'center' }}>Maintainers</h2>
        
        {/* Featured Maintainer */}
        <div style={{ 
          maxWidth: '450px', 
          margin: '0 auto 5rem auto', 
          textAlign: 'center',
          padding: '3rem 2rem',
          border: '1px solid var(--accent)',
          background: 'rgba(212, 175, 55, 0.05)',
          borderRadius: '4px'
        }}>
          <Image
            src="https://github.com/HimanM.png"
            alt="HimanM"
            width={100}
            height={100}
            unoptimized
            style={{ width: '100px', height: '100px', borderRadius: '50%', marginBottom: '1.5rem', border: '2px solid var(--accent)', padding: '4px' }}
          />
          <h3 style={{ fontSize: '1.75rem', marginBottom: '0.5rem' }}>HimanM</h3>
          <p style={{ color: 'var(--accent)', fontSize: '0.75rem', marginBottom: '2rem', fontFamily: 'var(--mono-font)', letterSpacing: '0.1em' }}>LEAD MAINTAINER</p>
          <div style={{ display: 'flex', justifyContent: 'center', gap: '1.5rem' }}>
            <a href="https://github.com/HimanM" className="button secondary" style={{ padding: '0.5rem 1.2rem', fontSize: '0.7rem' }}>GITHUB</a>
            <a href="https://www.linkedin.com/in/himanm/" className="button secondary" style={{ padding: '0.5rem 1.2rem', fontSize: '0.7rem' }}>LINKEDIN</a>
          </div>
        </div>

        <div style={{ 
          display: 'grid', 
          gridTemplateColumns: 'repeat(auto-fill, minmax(140px, 1fr))', 
          gap: '3rem' 
        }}>
          {filteredContributors.map(c => (
            <a key={c.id} href={c.html_url} target="_blank" rel="noopener noreferrer" style={{ textAlign: 'center' }} className="contributor-card">
              <Image
                src={c.avatar_url}
                alt={c.login}
                width={70}
                height={70}
                unoptimized
                style={{ width: '70px', height: '70px', borderRadius: '50%', marginBottom: '1rem', filter: 'grayscale(100%)', border: '1px solid var(--card-border)' }}
              />
              <p style={{ fontSize: '0.75rem', fontFamily: 'var(--mono-font)', color: 'var(--dimmed)' }}>{c.login}</p>
            </a>
          ))}
        </div>
      </section>

      {/* FAQ */}
      <section style={{ borderTop: '1px solid var(--card-border)', paddingBottom: '8rem' }}>
        <h2 style={{ fontSize: '2.5rem', marginBottom: '4rem', textAlign: 'center' }}>FAQ</h2>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '4rem' }}>
          <div>
            <h4 style={{ marginBottom: '1.25rem', color: 'var(--accent)', fontSize: '1.1rem' }}>What is BrokenOps?</h4>
            <p style={{ fontSize: '0.9rem', color: 'var(--dimmed)', lineHeight: 1.7 }}>
              BrokenOps is a community-driven platform for local Linux labs. Each lab starts broken on purpose so you can practice diagnosis, repair, and verification.
            </p>
          </div>
          <div>
            <h4 style={{ marginBottom: '1.25rem', color: 'var(--accent)', fontSize: '1.1rem' }}>How are recent labs selected?</h4>
            <p style={{ fontSize: '0.9rem', color: 'var(--dimmed)', lineHeight: 1.7 }}>
              The website builds a lab index from commit history in the <code>labs/</code> tree, then renders the newest lab folder updates first.
            </p>
          </div>
          <div>
            <h4 style={{ marginBottom: '1.25rem', color: 'var(--accent)', fontSize: '1.1rem' }}>How do I run it locally?</h4>
            <p style={{ fontSize: '0.9rem', color: 'var(--dimmed)', lineHeight: 1.7 }}>
              Clone the repo, use a native Linux host with KVM/libvirt, then run <code>./deploy.sh</code> and choose a lab from the dashboard.
            </p>
          </div>
          <div>
            <h4 style={{ marginBottom: '1.25rem', color: 'var(--accent)', fontSize: '1.1rem' }}>How can I contribute?</h4>
            <p style={{ fontSize: '0.9rem', color: 'var(--dimmed)', lineHeight: 1.7 }}>
              Open a PR with a new lab, documentation improvements, or verification fixes. The project is intentionally community-shaped.
            </p>
          </div>
        </div>
      </section>
    </main>
  );
}

