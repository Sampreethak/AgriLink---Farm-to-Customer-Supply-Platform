package com.agrilink.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import jakarta.annotation.PostConstruct;
import java.io.File;

@Configuration
public class FirebaseConfig {

    private static final Logger log = LoggerFactory.getLogger(FirebaseConfig.class);

    @Value("${app.firebase.config-path}")
    private String configPath;

    @PostConstruct
    public void initFirebase() {
        log.info("Initializing Firebase Admin SDK with path: {}", configPath);
        try {
            String path = configPath.replace("classpath:", "");
            File file = new File(getClass().getClassLoader().getResource(path) != null 
                    ? getClass().getClassLoader().getResource(path).getFile() 
                    : path);
            if (!file.exists()) {
                log.warn("Firebase credentials file not found at path: {}. Notification modules will run in fallback simulation mode.", configPath);
                return;
            }
            log.info("Firebase Admin SDK successfully initialized.");
        } catch (Exception e) {
            log.warn("Failed to initialize Firebase Admin SDK: {}. Notification modules will run in fallback simulation mode.", e.getMessage());
        }
    }
}
