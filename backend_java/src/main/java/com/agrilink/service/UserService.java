package com.agrilink.service;

import com.agrilink.entity.User;
import com.agrilink.exception.ResourceNotFoundException;
import com.agrilink.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional(readOnly = true)
    public User findById(UUID userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));
    }

    @Transactional(readOnly = true)
    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    @Transactional(readOnly = true)
    public Optional<User> findByPhone(String phone) {
        return userRepository.findByPhone(phone);
    }

    @Transactional(readOnly = true)
    public Optional<User> findByEmailOrPhone(String emailOrPhone) {
        return userRepository.findByEmailOrPhone(emailOrPhone);
    }

    @Transactional(readOnly = true)
    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    @Transactional(readOnly = true)
    public boolean existsByPhone(String phone) {
        return userRepository.existsByPhone(phone);
    }

    @Transactional
    public User save(User user) {
        return userRepository.save(user);
    }

    @Transactional
    public void updatePassword(UUID userId, String rawPassword) {
        User user = findById(userId);
        user.setPasswordHash(passwordEncoder.encode(rawPassword));
        userRepository.save(user);
        log.info("Password updated for user: {}", userId);
    }

    @Transactional
    public void deactivateUser(UUID userId) {
        User user = findById(userId);
        user.setStatus("Inactive");
        userRepository.save(user);
        log.info("User deactivated: {}", userId);
    }
}
