import { NextRequest, NextResponse } from "next/server";

const DIRECT_URLS = {
  pc: "https://github.com/creatorspara/equipo-kromium-vault/releases/latest/download/EquipoKromium-Windows.exe",
  android: "https://github.com/creatorspara/equipo-kromium-vault/releases/latest/download/EquipoKromium-Android.apk",
};

export async function GET(request: NextRequest) {
  const platform = (request.nextUrl.searchParams.get("platform") || "pc").toLowerCase();

  const targetUrl = platform === "android" ? DIRECT_URLS.android : DIRECT_URLS.pc;
  const filename = platform === "android" ? "EquipoKromium-Android.apk" : "EquipoKromium-Windows.exe";

  return NextResponse.redirect(targetUrl, {
    status: 302,
    headers: {
      "Content-Disposition": `attachment; filename="${filename}"`,
      "Cache-Control": "public, max-age=300",
    },
  });
}
