package vn.edu.fpt.converter;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import vn.edu.fpt.enums.OrderStatus;

@Converter(autoApply = true)
public class OrderStatusConverter implements AttributeConverter<OrderStatus, String> {
    @Override public String convertToDatabaseColumn(OrderStatus s) { return s == null ? null : s.getValue(); }
    @Override public OrderStatus convertToEntityAttribute(String s) { return s == null ? null : OrderStatus.fromValue(s); }
}
