package com.careeros.security.filter;

import com.careeros.security.jwt.JwtService;
import com.careeros.security.service.CustomUserDetailsService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final CustomUserDetailsService userDetailsService;

    public JwtAuthenticationFilter(
            JwtService jwtService,
            CustomUserDetailsService userDetailsService
    ) {
        this.jwtService = jwtService;
        this.userDetailsService = userDetailsService;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {

        String authHeader = request.getHeader("Authorization");

        System.out.println("========== JWT DEBUG ==========");
        System.out.println("Request URI : " + request.getRequestURI());
        System.out.println("Method      : " + request.getMethod());
        System.out.println("Auth Header : " +
                (authHeader != null ? "Bearer token present" : "NULL"));

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            System.out.println("JWT RESULT  : NO BEARER TOKEN");
            System.out.println("===============================");
            filterChain.doFilter(request, response);
            return;
        }

        String jwt = authHeader.substring(7);

        try {

            if (jwtService.isTokenValid(jwt)) {

                String email = jwtService.extractEmail(jwt);

                System.out.println("JWT Email   : " + email);

                UserDetails userDetails =
                        userDetailsService.loadUserByUsername(email);

                UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(
                                userDetails,
                                null,
                                userDetails.getAuthorities()
                        );

                authentication.setDetails(
                        new WebAuthenticationDetailsSource()
                                .buildDetails(request)
                );

                SecurityContextHolder.getContext()
                        .setAuthentication(authentication);

                System.out.println("Authenticated: "
                        + SecurityContextHolder
                        .getContext()
                        .getAuthentication()
                        .getName());

                System.out.println("JWT RESULT  : AUTHENTICATED");

            } else {

                System.out.println("JWT RESULT  : EXPIRED/INVALID");
            }

        } catch (Exception ex) {

            System.out.println("JWT RESULT  : INVALID TOKEN");
            System.out.println("JWT ERROR   : " + ex.getMessage());

            SecurityContextHolder.clearContext();
        }

        System.out.println("===============================");

        filterChain.doFilter(request, response);
    }
}