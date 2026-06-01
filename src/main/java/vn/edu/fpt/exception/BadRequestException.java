package vn.edu.fpt.exception;

/**
 * Thrown for invalid requests or business rule violations that should return HTTP 400.
 */
public class BadRequestException extends ApplicationException {

    private static final long serialVersionUID = 1L;

    public BadRequestException() {
        super();
    }

    public BadRequestException(String message) {
        super(message);
    }

    public BadRequestException(String message, Throwable cause) {
        super(message, cause);
    }
}

