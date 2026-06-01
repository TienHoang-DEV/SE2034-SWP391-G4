package vn.edu.fpt.converter;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import vn.edu.fpt.enums.LessonModerationStatus;

@Converter(autoApply = true)
public class LessonModerationStatusConverter implements AttributeConverter<LessonModerationStatus, String> {
    @Override public String convertToDatabaseColumn(LessonModerationStatus s) { return s == null ? null : s.getValue(); }
    @Override public LessonModerationStatus convertToEntityAttribute(String s) { return s == null ? null : LessonModerationStatus.fromValue(s); }
}
