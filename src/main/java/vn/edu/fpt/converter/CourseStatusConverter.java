package vn.edu.fpt.converter;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import vn.edu.fpt.enums.CourseStatus;

@Converter(autoApply = true)
public class CourseStatusConverter implements AttributeConverter<CourseStatus, String> {
    @Override public String convertToDatabaseColumn(CourseStatus s) { return s == null ? null : s.getValue(); }
    @Override public CourseStatus convertToEntityAttribute(String s) { return s == null ? null : CourseStatus.fromValue(s); }
}
