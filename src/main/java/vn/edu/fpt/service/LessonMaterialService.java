package vn.edu.fpt.service;

import com.azure.storage.blob.BlobClient;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import vn.edu.fpt.dto.LessonMaterialDto;
import vn.edu.fpt.entity.*;
import vn.edu.fpt.exception.ResourceNotFoundException;
import vn.edu.fpt.repository.CourseRepository;
import vn.edu.fpt.repository.CourseSectionRepository;
import vn.edu.fpt.repository.LessonMaterialRepository;
import vn.edu.fpt.repository.LessonRepository;
import vn.edu.fpt.service.cloud.AzureBlobService;
import vn.edu.fpt.util.AppConstants;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
@RequiredArgsConstructor
public class LessonMaterialService {



    private final LessonMaterialRepository repository;
    private final CourseRepository courseRepository;
    private final LessonRepository lessonRepository;
    private final AzureBlobService azureBlobService;
    private final CourseSectionRepository courseSectionRepository;


    public void saveAllMaterial(List<MultipartFile> file, Integer lessonId, User user){

        if(file == null || file.isEmpty()) return;

        Lesson lesson = lessonRepository.findById(lessonId).orElseThrow();

        for(MultipartFile f : file){
            if(f == null || f.isEmpty()) continue;

            String fileName = f.getOriginalFilename();
            String fileType = f.getContentType();
            Long fileSize = f.getSize();

            String url = azureBlobService.saveFile(f, "materials");
            LessonMaterial lessonMaterial = new LessonMaterial();
            lessonMaterial.setLesson(lesson);
            lessonMaterial.setFileType(fileName.substring(fileName.lastIndexOf(".") + 1));
            lessonMaterial.setFileName(fileName);
            lessonMaterial.setFileSize(fileSize);
            lessonMaterial.setFileUrl(url);
            lessonMaterial.setInstructor(user);
            lesson.setCreatedAt(LocalDateTime.now());

            repository.save(lessonMaterial);
        }

    }


    public ResponseEntity<InputStreamResource> dowloadFile(LessonMaterial lessonMaterial) {
        if (lessonMaterial == null) {
            return ResponseEntity.notFound().build();
        }
        BlobClient blobClient = azureBlobService.getBlobClient(
                AppConstants.AZURE_STORAGE_CONTAINER_MATERIALS,
                lessonMaterial.getFileUrl()
        );
        return azureBlobService.dowloadFile(blobClient);
    }

    @Transactional(readOnly = true)
    public List<LessonMaterialDto> getAllByInstructor(User instructor, Integer courseId) {
        List<LessonMaterial> entities;
        if (courseId != null) {
            entities = repository.findByInstructorIdAndCourseId(instructor.getId(), courseId);
        } else {
            entities = repository.findByInstructorId(instructor.getId());
        }
        return toDto(entities);
    }


    @Transactional(readOnly = true)
    public List<LessonMaterialDto> getByLessonId(Integer lessonId) {
        return toDto(repository.findByLesson_IdOrderByCreatedAtDesc(lessonId));
    }






    @Transactional(readOnly = true)
    public LessonMaterialDto findDtoById(Integer id) {
        LessonMaterial m = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy tài liệu với id = " + id));
        return toSingleDto(m);
    }


    public Optional<LessonMaterial> findById(Integer id) {
        return repository.findById(id);
    }

    public List<LessonMaterial> findAll() {
        return repository.findAll();
    }

    public LessonMaterial save(LessonMaterial entity) {
        return repository.save(entity);
    }

    public void deleteById(Integer id) {
        repository.deleteById(id);
    }

    public boolean existsById(Integer id) {
        return repository.existsById(id);
    }

    public Optional<LessonMaterial> findByLessonId(Integer lessonId) {
        return repository.findFirstByLesson_IdOrderByIdAsc(lessonId);
    }




    public void deleteMaterial(Integer materialId, User instructor) {
        LessonMaterial material = repository.findById(materialId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy tài liệu."));

        if (!material.getInstructor().getId().equals(instructor.getId())) {
            throw new SecurityException("Bạn không có quyền xóa tài liệu này.");
        }

        repository.delete(material);
    }



    private List<LessonMaterialDto> toDto(List<LessonMaterial> entities) {
        List<LessonMaterialDto> result = new ArrayList<>();
        for (LessonMaterial m : entities) {
            result.add(toSingleDto(m));
        }
        return result;
    }

    private LessonMaterialDto toSingleDto(LessonMaterial m) {
        LessonMaterialDto dto = new LessonMaterialDto();
        dto.setId(m.getId());
        dto.setFileName(m.getFileName());
        dto.setFileUrl(m.getFileUrl());
        dto.setFileType(m.getFileType());
        dto.setFileSize(m.getFileSize());
        dto.setCreatedAt(m.getCreatedAt());

        if (m.getCourse() != null) {
            dto.setCourseId(m.getCourse().getId());
            dto.setCourseTitle(m.getCourse().getTitle());
        }

        if (m.getLesson() != null) {
            dto.setLessonId(m.getLesson().getId());
            dto.setLessonTitle(m.getLesson().getTitle());
            if (m.getLesson().getCourseSection() != null) {
                dto.setSectionTitle(m.getLesson().getCourseSection().getTitle());
            }
        }
        return dto;
    }


    private String extractExtension(String filename) {
        if (filename == null || !filename.contains(".")) return "file";
        return filename.substring(filename.lastIndexOf('.') + 1).toLowerCase();
    }
}
