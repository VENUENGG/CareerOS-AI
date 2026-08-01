package com.careeros.skill.service.impl;

import com.careeros.exception.SkillNotFoundException;
import com.careeros.exception.UserProfileNotFoundException;
import com.careeros.security.service.AuthenticatedUserService;
import com.careeros.skill.dto.SkillRequest;
import com.careeros.skill.dto.SkillResponse;
import com.careeros.skill.entity.Skill;
import com.careeros.skill.mapper.SkillMapper;
import com.careeros.skill.repository.SkillRepository;
import com.careeros.skill.service.SkillService;
import com.careeros.user.entity.User;
import com.careeros.user.entity.UserProfile;
import com.careeros.user.repository.UserProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class SkillServiceImpl implements SkillService {

    private final SkillRepository skillRepository;
    private final UserProfileRepository userProfileRepository;
    private final AuthenticatedUserService authenticatedUserService;

    public SkillServiceImpl(
            SkillRepository skillRepository,
            UserProfileRepository userProfileRepository,
            AuthenticatedUserService authenticatedUserService
    ) {
        this.skillRepository = skillRepository;
        this.userProfileRepository = userProfileRepository;
        this.authenticatedUserService = authenticatedUserService;
    }

    private UserProfile getCurrentUserProfile() {

        User currentUser =
                authenticatedUserService.getCurrentUser();

        return userProfileRepository.findByUser(currentUser)
                .orElseThrow(() ->
                        new UserProfileNotFoundException(
                                "User profile not found."
                        )
                );
    }
    @Override
    public SkillResponse createSkill(
            SkillRequest request
    ) {

        UserProfile userProfile = getCurrentUserProfile();

        Skill skill = new Skill();

        skill.setUserProfile(userProfile);

        SkillMapper.mapRequestToEntity(
                request,
                skill
        );

        Skill savedSkill =
                skillRepository.save(skill);

        return SkillMapper.mapEntityToResponse(savedSkill);
    }

    @Override
    @Transactional(readOnly = true)
    public java.util.List<SkillResponse> getMySkills() {

        UserProfile userProfile = getCurrentUserProfile();

        return skillRepository.findByUserProfile(userProfile)
                .stream()
                .map(SkillMapper::mapEntityToResponse)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public SkillResponse getSkillById(Long id) {

        UserProfile userProfile = getCurrentUserProfile();

        Skill skill = skillRepository
                .findByIdAndUserProfile(id, userProfile)
                .orElseThrow(() ->
                        new SkillNotFoundException(
                                "Skill not found."
                        )
                );

        return SkillMapper.mapEntityToResponse(skill);
    }

    @Override
    public SkillResponse updateSkill(
            Long id,
            SkillRequest request
    ) {

        UserProfile userProfile = getCurrentUserProfile();

        Skill skill = skillRepository
                .findByIdAndUserProfile(id, userProfile)
                .orElseThrow(() ->
                        new SkillNotFoundException(
                                "Skill not found."
                        )
                );

        SkillMapper.mapRequestToEntity(
                request,
                skill
        );

        Skill updatedSkill =
                skillRepository.save(skill);

        return SkillMapper.mapEntityToResponse(updatedSkill);
    }

    @Override
    public void deleteSkill(Long id) {

        UserProfile userProfile = getCurrentUserProfile();

        Skill skill = skillRepository
                .findByIdAndUserProfile(id, userProfile)
                .orElseThrow(() ->
                        new SkillNotFoundException(
                                "Skill not found."
                        )
                );

        skillRepository.delete(skill);
    }
}