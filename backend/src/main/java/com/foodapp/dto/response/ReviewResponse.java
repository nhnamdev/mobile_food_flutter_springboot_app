package com.foodapp.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReviewResponse {
    private Long id;
    private Long orderId;
    private Long customerId;
    private String customerName;
    private String customerAvatar;
    private Long shopId;
    private Integer rating;
    private String comment;
    private String images;
    private String shopReply;
    private OffsetDateTime repliedAt;
    private OffsetDateTime createdAt;
}
