package vn.edu.fpt.service;

import com.azure.storage.blob.BlobClient;
import com.azure.storage.blob.BlobServiceClient;
import com.azure.storage.blob.BlobServiceClientBuilder;
import com.azure.storage.blob.sas.BlobSasPermission;
import com.azure.storage.blob.sas.BlobServiceSasSignatureValues;
import org.springframework.stereotype.Service;
import vn.edu.fpt.util.AppConstants;

import java.time.OffsetDateTime;

@Service
public class AzureBlobService {

    // Đối tượng client chính để giao tiếp với Azure Blob Storage.
    private BlobServiceClient blobServiceClient;

    public AzureBlobService() {
        // Chuỗi kết nối Azure Storage đã được nạp từ file .env hoặc JVM args.
        String connectionString = System.getProperty("AZURE_STORAGE_CONNECTION_STRING");
        // Tạo client để thao tác với Azure Blob Storage.
        this.blobServiceClient = new BlobServiceClientBuilder()
                .connectionString(connectionString)
                .buildClient();
    }

    // Tạo URL SAS có quyền đọc cho một file trong container xác định.
    public String generateSasUrl(String containerName, String blobName) {
        // Lấy blob client theo tên container và tên file.
        String decodedBlobName = java.net.URLDecoder.decode(blobName, java.nio.charset.StandardCharsets.UTF_8);
        BlobClient blobClient = blobServiceClient
                .getBlobContainerClient(containerName)
                .getBlobClient(decodedBlobName);

        // Cấu hình thời gian hết hạn và quyền truy cập của SAS.
        BlobServiceSasSignatureValues sasValues = new BlobServiceSasSignatureValues(
                OffsetDateTime.now().plusHours(AppConstants.SAS_EXPIRATION_HOURS), new BlobSasPermission().setReadPermission(true)
        );

        // Ghép URL gốc của blob với chuỗi SAS để trả về link truy cập tạm thời.
        return blobClient.getBlobUrl() + "?" + blobClient.generateSas(sasValues);
    }
}
