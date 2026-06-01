package vn.edu.fpt.converter;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import vn.edu.fpt.enums.InstructorRequestStatus;

@Converter(autoApply = true)
public class InstructorRequestStatusConverter implements AttributeConverter<InstructorRequestStatus, String> {
    @Override public String convertToDatabaseColumn(InstructorRequestStatus s) { return s == null ? null : s.getValue(); }
    @Override public InstructorRequestStatus convertToEntityAttribute(String s) { return s == null ? null : InstructorRequestStatus.fromValue(s); }
}
