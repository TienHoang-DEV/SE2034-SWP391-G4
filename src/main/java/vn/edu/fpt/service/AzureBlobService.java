package vn.edu.fpt.service;

import com.azure.storage.blob.BlobClient;
import com.azure.storage.blob.BlobServiceClient;
import com.azure.storage.blob.BlobServiceClientBuilder;
import com.azure.storage.blob.models.BlobHttpHeaders;
import com.azure.storage.blob.sas.BlobSasPermission;
import com.azure.storage.blob.sas.BlobServiceSasSignatureValues;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import vn.edu.fpt.util.AppConstants;

import java.time.OffsetDateTime;
import java.util.UUID;

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

    public String saveFile(MultipartFile file, String containerName) {

        try {
            String filename = UUID.randomUUID() + "_" + file.getOriginalFilename();
            BlobClient blobClient = blobServiceClient.getBlobContainerClient(containerName).getBlobClient(filename);

            blobClient.upload(file.getInputStream(), file.getSize(), true);

            blobClient.setHttpHeaders(new BlobHttpHeaders().setContentType(file.getContentType()));
            return blobClient.getBlobUrl();
        } catch (Exception e) {
            throw new RuntimeException("Error");
        }

    }

    public String generateSasUrl(String containerName, String blobName) {
        // Lấy blob client theo tên container và tên file.
        String decodedBlobName = java.net.URLDecoder.decode(blobName, java.nio.charset.StandardCharsets.UTF_8);
        BlobClient blobClient = blobServiceClient
                .getBlobContainerClient(containerName)
                .getBlobClient(decodedBlobName); //  .getBlobClient chỉ nhận tham số là tên file



        // Cấu hình thời gian hết hạn và quyền truy cập của SAS.
        BlobServiceSasSignatureValues sasValues = new BlobServiceSasSignatureValues(
                OffsetDateTime.now().plusHours(AppConstants.SAS_EXPIRATION_HOURS), new BlobSasPermission().setReadPermission(true)
        );

        // Ghép URL gốc của blob với chuỗi SAS để trả về link truy cập tạm thời.
        return blobClient.getBlobUrl() + "?" + blobClient.generateSas(sasValues);
    }
}
