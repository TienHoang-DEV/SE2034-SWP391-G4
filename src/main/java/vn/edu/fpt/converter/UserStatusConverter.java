package vn.edu.fpt.converter;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import vn.edu.fpt.enums.UserStatus;

@Converter(autoApply = true)
public class UserStatusConverter implements AttributeConverter<UserStatus, String> {
    @Override public String convertToDatabaseColumn(UserStatus s) { return s == null ? null : s.getValue(); }
    @Override public UserStatus convertToEntityAttribute(String s) { return s == null ? null : UserStatus.fromValue(s); }
}
