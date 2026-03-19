import UIKit
import Network

final class DeviceInfoService {

    static let shared = DeviceInfoService()
    private init() {}

    /// A persistent device ID stored in Keychain, generated once per install.
    var deviceId: String {
        let service = "com.abby.device"
        let account = "deviceId"
        if let existing = KeychainHelper.shared.get(service: service, account: account) {
            return existing
        }
        let newId = UUID().uuidString
        _ = KeychainHelper.shared.save(token: newId, service: service, account: account)
        return newId
    }

    /// Timezone in UTC offset format, e.g. "UTC+01:00"
    var timezone: String {
        let seconds = TimeZone.current.secondsFromGMT()
        let hours = abs(seconds) / 3600
        let minutes = (abs(seconds) % 3600) / 60
        let sign = seconds >= 0 ? "+" : "-"
        return "UTC\(sign)\(String(format: "%02d", hours)):\(String(format: "%02d", minutes))"
    }

    /// Screen info: width, height, scaling factor, colour depth
    var screens: String {
        let screen = UIScreen.main
        let w = Int(screen.bounds.width)
        let h = Int(screen.bounds.height)
        let scale = Int(screen.scale)
        return "width=\(w)&height=\(h)&scaling-factor=\(scale)&colour-depth=32"
    }

    /// Window size (matches screen for mobile)
    var windowSize: String {
        let screen = UIScreen.main
        let w = Int(screen.bounds.width)
        let h = Int(screen.bounds.height)
        return "width=\(w)&height=\(h)"
    }

    /// Device user agent string in HMRC format
    var userAgent: String {
        let device = UIDevice.current
        let osVersion = device.systemVersion
        var model = device.model // "iPhone" / "iPad"

        // Get specific model identifier
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        } ?? model

        let encoded = machine.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? machine
        return "os-family=iOS&os-version=\(osVersion)&device-manufacturer=Apple&device-model=\(encoded)"
    }

    /// Local IP addresses (IPv4 and IPv6)
    var localIPs: String {
        var addresses: [String] = []
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return ""
        }
        defer { freeifaddrs(ifaddr) }

        var ptr = firstAddr
        while true {
            let interface = ptr.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                let name = String(cString: interface.ifa_name)
                if name == "en0" || name == "pdp_ip0" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                    let address = String(cString: hostname)
                    let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? address
                    addresses.append(encoded)
                }
            }
            guard let next = interface.ifa_next else { break }
            ptr = next
        }
        return addresses.joined(separator: ",")
    }

    /// Apply all fraud-prevention device headers to a URLRequest
    func applyHeaders(to request: inout URLRequest) {
        let now = ISO8601DateFormatter().string(from: Date())
        request.setValue(deviceId, forHTTPHeaderField: "X-Device-ID")
        request.setValue(localIPs, forHTTPHeaderField: "X-Device-Local-IPs")
        request.setValue(now, forHTTPHeaderField: "X-Device-Local-IPs-Timestamp")
        request.setValue(screens, forHTTPHeaderField: "X-Device-Screens")
        request.setValue(timezone, forHTTPHeaderField: "X-Device-Timezone")
        request.setValue(userAgent, forHTTPHeaderField: "X-Device-User-Agent")
        request.setValue(windowSize, forHTTPHeaderField: "X-Device-Window-Size")
    }
}
