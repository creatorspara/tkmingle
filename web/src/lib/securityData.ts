export interface ScanEngineResult {
  engine: string;
  verdict: "Not Detected" | "Not Supported";
  definitionDate: string;
}

export interface SecurityReport {
  dataId: string;
  fileName: string;
  fileSize: string;
  fileSizeBytes: number;
  extension: string;
  fileTypeDescription: string;
  md5: string;
  sha1: string;
  sha256: string;
  uploadTimestamp: string;
  scanDuration: string;
  generatedDate: string;
  threatsDetected: number;
  totalEngines: number;
  cleanEngines: number;
  unsupportedEngines: number;
  verdictText: string;
  pdfUrl: string;
  previewImages: {
    page1: string;
    page2: string;
  };
  engines: ScanEngineResult[];
}

export const METADEFENDER_REPORT: SecurityReport = {
  dataId: "bzI2MTEyMm5kaE9vbzlhTXE3elM2bVI4dzJ1_mdaas",
  fileName: "tkmmingle-k1-release.apk",
  fileSize: "64.3 MB",
  fileSizeBytes: 67456380,
  extension: "apk",
  fileTypeDescription: "Android Application Package",
  md5: "13FED6EC97561BE1366AB69E43BE6CC9",
  sha1: "4830EB1EF3C63BA873056475075BA671FD46392B",
  sha256: "57E805E9C59E4F3D2EA8FAB706E78B7D5507BC7BA7C82EA75B10D860B26DA4A8",
  uploadTimestamp: "Sun Nov 22 2026 17:59:21 GMT+0530",
  scanDuration: "2102 ms",
  generatedDate: "November 22, 2026 at 18:04",
  threatsDetected: 0,
  totalEngines: 21,
  cleanEngines: 19,
  unsupportedEngines: 2,
  verdictText: "No threats detected (0/21 Clean)",
  pdfUrl: "/tkmmingle-k1-release.apk.pdf",
  previewImages: {
    page1: "/images/metadefender-scan-page1.png",
    page2: "/images/metadefender-scan-page2.png",
  },
  engines: [
    { engine: "Bitdefender", verdict: "Not Detected", definitionDate: "November 22, 2026" },
    { engine: "Sophos", verdict: "Not Detected", definitionDate: "November 22, 2026" },
    { engine: "ESET", verdict: "Not Detected", definitionDate: "November 21, 2026" },
    { engine: "SentinelOne", verdict: "Not Detected", definitionDate: "November 22, 2026" },
    { engine: "Trellix", verdict: "Not Detected", definitionDate: "November 21, 2026" },
    { engine: "ClamAV", verdict: "Not Detected", definitionDate: "November 22, 2026" },
    { engine: "Avira", verdict: "Not Detected", definitionDate: "November 22, 2026" },
    { engine: "AhnLab", verdict: "Not Detected", definitionDate: "November 22, 2026" },
    { engine: "Quick Heal", verdict: "Not Detected", definitionDate: "November 22, 2026" },
    { engine: "OPSWAT Predictive Alin AI", verdict: "Not Detected", definitionDate: "November 21, 2026" },
    { engine: "Bkav Pro", verdict: "Not Detected", definitionDate: "November 21, 2026" },
    { engine: "CMC", verdict: "Not Detected", definitionDate: "November 21, 2026" },
    { engine: "Xcitium", verdict: "Not Detected", definitionDate: "November 21, 2026" },
    { engine: "IKARUS", verdict: "Not Detected", definitionDate: "November 22, 2026" },
    { engine: "K7", verdict: "Not Detected", definitionDate: "November 22, 2026" },
    { engine: "Lionic", verdict: "Not Detected", definitionDate: "November 22, 2026" },
    { engine: "TACHYON", verdict: "Not Detected", definitionDate: "November 22, 2026" },
    { engine: "Varist", verdict: "Not Detected", definitionDate: "November 21, 2026" },
    { engine: "Xvirus Anti-Malware", verdict: "Not Detected", definitionDate: "November 22, 2026" },
    { engine: "Aurora", verdict: "Not Supported", definitionDate: "November 22, 2026" },
    { engine: "Webroot SMD", verdict: "Not Supported", definitionDate: "November 22, 2026" },
  ],
};
