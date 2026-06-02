package vn.edu.fpt.exception;

/**
 * Base runtime exception for the application.
 */
public class ApplicationException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public ApplicationException() {
        super();
    }

    public ApplicationException(String message) {
        super(message);
    }

    public ApplicationException(String message, Throwable cause) {
        super(message, cause);
    }

    public ApplicationException(Throwable cause) {
        super(cause);
    }
}

