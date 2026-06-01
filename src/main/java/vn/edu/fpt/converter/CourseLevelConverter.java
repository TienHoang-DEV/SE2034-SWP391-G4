package vn.edu.fpt.converter;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import vn.edu.fpt.enums.CourseLevel;

@Converter(autoApply = true)
public class CourseLevelConverter implements AttributeConverter<CourseLevel, String> {
    @Override public String convertToDatabaseColumn(CourseLevel s) { return s == null ? null : s.getValue(); }
    @Override public CourseLevel convertToEntityAttribute(String s) { return s == null ? null : CourseLevel.fromValue(s); }
}
