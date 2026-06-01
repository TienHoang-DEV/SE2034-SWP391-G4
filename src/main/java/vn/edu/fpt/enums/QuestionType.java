package vn.edu.fpt.enums;

public enum QuestionType {
    SINGLE("single"), MULTIPLE("multiple");

    private final String value;
    QuestionType(String value) { this.value = value; }
    public String getValue() { return value; }
    public static QuestionType fromValue(String value) {
        for (QuestionType s : values()) if (s.value.equals(value)) return s;
        throw new IllegalArgumentException("Unknown QuestionType: " + value);
    }
}
