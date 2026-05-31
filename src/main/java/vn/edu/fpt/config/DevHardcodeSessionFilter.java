package vn.edu.fpt.config;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import vn.edu.fpt.repository.UserRepository;

import java.io.IOException;

/**
 * Dev-only (hard-code) filter that ensures a session contains userId=4 and
 * currentUser loaded from DB.
 * WARNING: This affects every request in the running application. Remove or
 * gate by @Profile("dev") before production.
 */
@Component
@Order(1)
public class DevHardcodeSessionFilter implements Filter {

    private final UserRepository userRepository;

    public DevHardcodeSessionFilter(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        if (request instanceof HttpServletRequest) {
            HttpServletRequest req = (HttpServletRequest) request;
            HttpSession session = req.getSession();

            // Always set userId=4 if not present
            if (session.getAttribute("user") == null) {
                session.setAttribute("userId", 4);
                // Try to load user entity from DB and store in session for convenience
                try {
                    userRepository.findById(4).ifPresent(u -> session.setAttribute("user", u));
                } catch (Exception ignored) {
                    // If DB not available at startup, ignore — filter will not crash requests
                }
            }
        }

        chain.doFilter(request, response);
    }
}
