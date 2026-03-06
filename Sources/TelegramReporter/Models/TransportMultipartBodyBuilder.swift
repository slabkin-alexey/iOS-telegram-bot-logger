import Foundation

struct TransportMultipartBodyBuilder {
    private let boundary: String
    private let lineBreak = "\r\n"
    private var body = Data()

    init(boundary: String) {
        self.boundary = boundary
    }

    mutating func addTextField(name: String, value: String) {
        append("--\(boundary)\(lineBreak)")
        append("Content-Disposition: form-data; name=\"\(name)\"\(lineBreak)\(lineBreak)")
        append("\(value)\(lineBreak)")
    }

    mutating func addFileField(name: String, attachment: TransportAttachment) {
        append("--\(boundary)\(lineBreak)")
        append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(attachment.fileName)\"\(lineBreak)")
        append("Content-Type: \(attachment.mimeType)\(lineBreak)\(lineBreak)")
        body.append(attachment.data)
        append(lineBreak)
    }

    mutating func finalize() {
        append("--\(boundary)--\(lineBreak)")
    }

    func build() -> Data {
        body
    }

    private mutating func append(_ value: String) {
        body.append(Data(value.utf8))
    }
}
