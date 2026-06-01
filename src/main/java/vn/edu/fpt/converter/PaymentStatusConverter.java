package vn.edu.fpt.converter;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import vn.edu.fpt.enums.PaymentStatus;

@Converter(autoApply = true)
public class PaymentStatusConverter implements AttributeConverter<PaymentStatus, String> {
    @Override public String convertToDatabaseColumn(PaymentStatus s) { return s == null ? null : s.getValue(); }
    @Override public PaymentStatus convertToEntityAttribute(String s) { return s == null ? null : PaymentStatus.fromValue(s); }
}
