package com.agrilink.service;

import com.agrilink.entity.Return;
import com.agrilink.entity.Refund;
import com.agrilink.exception.BadRequestException;
import com.agrilink.exception.ResourceNotFoundException;
import com.agrilink.repository.ReturnRepository;
import com.agrilink.repository.RefundRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReturnService {

    private final ReturnRepository returnRepository;
    private final RefundRepository refundRepository;

    @Transactional(readOnly = true)
    public Return findById(UUID returnId) {
        return returnRepository.findById(returnId)
                .orElseThrow(() -> new ResourceNotFoundException("Return request not found: " + returnId));
    }

    @Transactional(readOnly = true)
    public Page<Return> getCustomerReturns(UUID customerId, Pageable pageable) {
        return returnRepository.findByCustomer_CustomerId(customerId, pageable);
    }

    @Transactional(readOnly = true)
    public Page<Return> getReturnsByStatus(String status, Pageable pageable) {
        return returnRepository.findByStatus(status, pageable);
    }

    @Transactional
    public Return save(Return returnRequest) {
        return returnRepository.save(returnRequest);
    }

    @Transactional
    public Return approveReturn(UUID returnId, UUID reviewedByUserId) {
        Return returnRequest = findById(returnId);
        if (!"Requested".equals(returnRequest.getStatus())) {
            throw new BadRequestException("Return is already in status: " + returnRequest.getStatus());
        }
        returnRequest.setStatus("Approved");
        log.info("Return {} approved", returnId);
        return returnRepository.save(returnRequest);
    }

    @Transactional
    public Return rejectReturn(UUID returnId, UUID reviewedByUserId) {
        Return returnRequest = findById(returnId);
        returnRequest.setStatus("Rejected");
        log.info("Return {} rejected", returnId);
        return returnRepository.save(returnRequest);
    }
}
