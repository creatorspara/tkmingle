import { NextRequest, NextResponse } from "next/server";

export async function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams;
  const inputUrl = searchParams.get("url")?.trim();

  if (!inputUrl) {
    return NextResponse.json({ error: "Missing url parameter" }, { status: 400 });
  }

  let parsed: URL;
  try {
    parsed = new URL(inputUrl);
  } catch (err) {
    return NextResponse.json({ error: "Invalid URL format" }, { status: 400 });
  }

  const hostname = parsed.hostname.toLowerCase();

  // Enforce ONLY ImgBB
  if (hostname === "i.ibb.co") {
    return NextResponse.json({ direct_url: inputUrl, is_direct: true });
  }

  if (hostname !== "ibb.co" && hostname !== "www.ibb.co") {
    return NextResponse.json(
      {
        error: "Only ImgBB links (ibb.co or i.ibb.co) are allowed on TKMingle. Please upload your photo to https://imgbb.com.",
      },
      { status: 400 }
    );
  }

  try {
    const res = await fetch(inputUrl, {
      headers: {
        "User-Agent": "Mozilla/5.0 (compatible; TKMingleImgBB/1.0)",
        Accept: "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      },
      redirect: "follow",
    });

    if (!res.ok) {
      return NextResponse.json(
        { error: `ImgBB page returned HTTP ${res.status}. The image may be deleted or private.` },
        { status: 400 }
      );
    }

    const html = await res.text();

    // 1. Check og:image or twitter:image metadata tags
    const ogMatch =
      html.match(
        /<meta[^>]+(?:property|name)=["'](?:og:image|twitter:image|twitter:image:src)["'][^>]+content=["']([^"']+)["']/i
      ) ||
      html.match(
        /<meta[^>]+content=["']([^"']+)["'][^>]+(?:property|name)=["'](?:og:image|twitter:image|twitter:image:src)["']/i
      );

    if (ogMatch && ogMatch[1] && ogMatch[1].includes("i.ibb.co")) {
      return NextResponse.json({ direct_url: ogMatch[1], page_url: inputUrl });
    }

    // 2. Fallback: Search the HTML for direct i.ibb.co image URLs
    const directMatches = html.match(/https?:\/\/i\.ibb\.co\/[^"'<>\s\\]+/gi);
    if (directMatches && directMatches.length > 0) {
      const candidate = directMatches[0].replace(/&amp;/g, "&");
      return NextResponse.json({ direct_url: candidate, page_url: inputUrl });
    }

    return NextResponse.json(
      {
        error:
          "Could not find a direct image link on this ImgBB page. Make sure the image is public and not deleted.",
      },
      { status: 404 }
    );
  } catch (err: any) {
    return NextResponse.json(
      { error: "Failed to connect to ImgBB: " + (err.message || String(err)) },
      { status: 500 }
    );
  }
}
