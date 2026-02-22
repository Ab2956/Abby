class FraudPreventionBuilder {
    constructor() {
        this.headers = {};
    }

    async buildHeaders(deviceInfo, userId) {
        // needs to be percent encoded as per HMRC requirements
        return {
            "Gov-Client-Connection-Method": deviceInfo.connectionMethod || "MOBILE_APP_VIA_SERVER",
            "Gov-Client-Device-ID": deviceInfo.deviceId || "unknown-device-id",
            "Gov-Client-Local-IPs": deviceInfo.localIPs || "unknown-local-ips",
            "Gov-Client-Local-IPs-Timestamp": deviceInfo.localIPsTimestamp || new Date().toISOString(),
            "Gov-Client-Public-IP": deviceInfo.publicIP || "unknown-public-ip",
            "Gov-Client-Public-IP-Timestamp": deviceInfo.publicIPTimestamp || new Date().toISOString(),
            "Gov-Client-Public-Port": deviceInfo.publicPort || "unknown-public-port",
            "Gov-Client-Screens": deviceInfo.screens || "unknown-screens",
            "Gov-Client-Timezone": deviceInfo.timezone || "unknown-timezone",
            "Gov-Client-User-Agent": deviceInfo.userAgent || "unknown-user-agent",
            "Gov-Client-User-IDs": `Abby=${userId}`,
            "Gov-Client-Window-Size": deviceInfo.windowSize || "unknown-window-size",
            "Gov-Vendor-Forwarded": deviceInfo.vendorForwarded || "unknown-vendor-forwarded",
            "Gov-Vendor-License-IDs": deviceInfo.vendorLicenseIds || "unknown-vendor-license-ids",
            "Gov-Vendor-Product-Name": deviceInfo.vendorProductName || "unknown-vendor-product-name",
            "Gov-Vendor-Public-IP": deviceInfo.vendorPublicIP || "unknown-vendor-public-ip",
            "Gov-Vendor-Version": deviceInfo.vendorVersion || "unknown-vendor-version",
        };
    }

}