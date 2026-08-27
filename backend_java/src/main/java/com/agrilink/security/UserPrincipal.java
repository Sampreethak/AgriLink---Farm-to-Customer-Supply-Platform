package com.agrilink.security;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;
import java.util.UUID;

public class UserPrincipal implements UserDetails {
    private final UUID id;
    private final String phone;
    private final String email;
    private final String password;
    private final Collection<? extends GrantedAuthority> authorities;

    public UserPrincipal(UUID id, String phone, String email, String password, Collection<? extends GrantedAuthority> authorities) {
        this.id = id;
        this.phone = phone;
        this.email = email;
        this.password = password;
        this.authorities = authorities;
    }

    public static UserPrincipal create(UUID id, String phone, String email, String password, String role) {
        SimpleGrantedAuthority authority = new SimpleGrantedAuthority("ROLE_" + role.toUpperCase().replace(" ", "_"));
        return new UserPrincipal(
                id,
                phone,
                email,
                password,
                Collections.singletonList(authority)
        );
    }

    public UUID getId() {
        return id;
    }

    public String getPhone() {
        return phone;
    }

    public String getEmail() {
        return email;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getUsername() {
        return phone != null ? phone : email;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }
}
