const os = require('os');

class FraudPreventionBuilder {
    constructor() {
        this.headers = {};
    }

    // Percent encode values for headers
    percentEncode(value) {
        if (!value) return '';
        return encodeURIComponent(String(value))
            .replace(/!/g, '%21')
            .replace(/'/g, '%27')
            .replace(/\(/g, '%28')
            .replace(/\)/g, '%29')
            .replace(/\*/g, '%2A');
    }

    /**
     * Get the server's local IP addresses.
     */
    getServerIPs() {
        const interfaces = os.networkInterfaces();
        const ips = [];
        for (const name of Object.keys(interfaces)) {
            for (const iface of interfaces[name]) {
                if (!iface.internal) {
                    ips.push(iface.address);
                }
            }
        }
        return ips.join(',') || '127.0.0.1';
    }

// Build the headers required for HMRC API calls
    async buildHeaders(deviceInfo, userId, req) {
        const now = new Date().toISOString();

        // Server-derived values
        const clientPublicIP = req.headers['x-forwarded-for']?.split(',')[0]?.trim()
            || req.socket?.remoteAddress
            || '';
        const clientPublicPort = String(req.socket?.remotePort || '');
        const serverIP = this.getServerIPs();
        const vendorForwarded = `by=${serverIP}&for=${clientPublicIP}`;

        return {
            "Gov-Client-Connection-Method": "MOBILE_APP_VIA_SERVER",
            "Gov-Client-Device-ID": deviceInfo.deviceId || '',
            "Gov-Client-Local-IPs": deviceInfo.localIPs || '',
            "Gov-Client-Local-IPs-Timestamp": deviceInfo.localIPsTimestamp || now,
            "Gov-Client-Public-IP": clientPublicIP,
            "Gov-Client-Public-IP-Timestamp": now,
            "Gov-Client-Public-Port": clientPublicPort,
            "Gov-Client-Screens": deviceInfo.screens || '',
            "Gov-Client-Timezone": deviceInfo.timezone || '',
            "Gov-Client-User-Agent": deviceInfo.userAgent || '',
            "Gov-Client-User-IDs": `Abby=${this.percentEncode(userId)}`,
            "Gov-Client-Window-Size": deviceInfo.windowSize || '',
            "Gov-Vendor-Forwarded": vendorForwarded,
            "Gov-Vendor-License-IDs": `Abby=${this.percentEncode(process.env.VENDOR_LICENSE_ID || '')}`,
            "Gov-Vendor-Product-Name": this.percentEncode("Abby"),
            "Gov-Vendor-Public-IP": serverIP,
            "Gov-Vendor-Version": `Abby=${this.percentEncode(process.env.APP_VERSION || '1.0.0')}`,
        };
    }

    // extract the device info
    extractDeviceInfo(req) {
        return {
            deviceId: req.headers['x-device-id'] || '',
            localIPs: req.headers['x-device-local-ips'] || '',
            localIPsTimestamp: req.headers['x-device-local-ips-timestamp'] || '',
            screens: req.headers['x-device-screens'] || '',
            timezone: req.headers['x-device-timezone'] || '',
            userAgent: req.headers['x-device-user-agent'] || '',
            windowSize: req.headers['x-device-window-size'] || '',
        };
    }
}

module.exports = new FraudPreventionBuilder();