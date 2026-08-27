package com.agrilink.security;

import com.agrilink.entity.User;
import com.agrilink.repository.UserRepository;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    public CustomUserDetailsService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    @Transactional
    public UserDetails loadUserByUsername(String phoneOrEmail) throws UsernameNotFoundException {
        User user = userRepository.findByPhoneOrEmail(phoneOrEmail, phoneOrEmail)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with phone or email: " + phoneOrEmail));
        return UserPrincipal.create(user.getUserId(), user.getPhone(), user.getEmail(), user.getPasswordHash(), user.getRole().getRoleName());
    }

    @Transactional
    public UserDetails loadUserById(UUID id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with id: " + id));
        return UserPrincipal.create(user.getUserId(), user.getPhone(), user.getEmail(), user.getPasswordHash(), user.getRole().getRoleName());
    }
}
