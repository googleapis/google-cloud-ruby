# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


module Google
  module Cloud
    module Talent
      module V4beta1
        # A resource that represents the profile for a job candidate (also referred to
        # as a "single-source profile"). A profile belongs to a
        # {Google::Cloud::Talent::V4beta1::Tenant Tenant}, which is an isolated instance
        # of the customer that owns the profile.
        # @!attribute [rw] name
        #   @return [String]
        #     Required during profile update.
        #
        #     Resource name assigned to a profile by the API.
        #
        #     The format is
        #     "projects/{project_id}/tenants/{tenant_id}/profiles/{profile_id}",
        #     for example, "projects/api-test-project/tenants/foo/profiles/bar".
        # @!attribute [rw] external_id
        #   @return [String]
        #     Optional.
        #
        #     Profile's id in client system if available.
        #
        #     The maximum number of bytes allowed is 100.
        # @!attribute [rw] source
        #   @return [String]
        #     Optional.
        #
        #     The source description indicating where the profile is acquired.
        #
        #     For example, if a candidate profile is acquired from a resume, the user can
        #     input "resume" here to indicate the source.
        #
        #     The maximum number of bytes allowed is 100.
        # @!attribute [rw] uri
        #   @return [String]
        #     Optional.
        #
        #     The URI set by clients that links to this profile's client-side copy.
        #
        #     The maximum number of bytes allowed is 4000.
        # @!attribute [rw] group_id
        #   @return [String]
        #     Optional.
        #
        #     The cluster id of the profile to associate with other profile(s) for the
        #     same candidate.
        #
        #     A random UUID is assigned if
        #     {Google::Cloud::Talent::V4beta1::Profile#group_id group_id} isn't provided. To
        #     ensure global uniqueness, customized
        #     {Google::Cloud::Talent::V4beta1::Profile#group_id group_id} isn't supported.
        #     If {Google::Cloud::Talent::V4beta1::Profile#group_id group_id} is set, there
        #     must be at least one other profile with the same system generated
        #     {Google::Cloud::Talent::V4beta1::Profile#group_id group_id}, otherwise an
        #     error is thrown.
        #
        #     This is used to link multiple profiles to the same candidate. For example,
        #     a client has a candidate with two profiles, where one was created recently
        #     and the other one was created 5 years ago. These two profiles may be very
        #     different. The clients can create the first profile and get a generated
        #     {Google::Cloud::Talent::V4beta1::Profile#group_id group_id}, and assign it
        #     when the second profile is created, indicating these two profiles are
        #     referring to the same candidate.
        # @!attribute [rw] is_hirable
        #   @return [Google::Protobuf::BoolValue]
        #     Optional.
        #
        #     Indicates the hirable status of the candidate.
        # @!attribute [rw] create_time
        #   @return [Google::Protobuf::Timestamp]
        #     Optional.
        #
        #     The timestamp when the profile was first created at this source.
        # @!attribute [rw] update_time
        #   @return [Google::Protobuf::Timestamp]
        #     Optional.
        #
        #     The timestamp when the profile was last updated at this source.
        # @!attribute [rw] resume_hrxml
        #   @return [String]
        #     Optional.
        #
        #     The profile contents in HR-XML format.
        #     See http://schemas.liquid-technologies.com/hr-xml/2007-04-15/ for more
        #     information about Human Resources XML.
        #
        #     Users can create a profile with only
        #     {Google::Cloud::Talent::V4beta1::Profile#resume_hrxml resume_hrxml} field. For
        #     example, the API parses the
        #     {Google::Cloud::Talent::V4beta1::Profile#resume_hrxml resume_hrxml} and
        #     creates a profile with all structured fields populated, for example.
        #     {Google::Cloud::Talent::V4beta1::EmploymentRecord EmploymentRecord},
        #     {Google::Cloud::Talent::V4beta1::EducationRecord EducationRecord}, etc. An
        #     error is thrown if the
        #     {Google::Cloud::Talent::V4beta1::Profile#resume_hrxml resume_hrxml} can't be
        #     parsed.
        #
        #     If the {Google::Cloud::Talent::V4beta1::Profile#resume_hrxml resume_hrxml} is
        #     provided during profile creation or update, any other structured data
        #     provided in the profile is ignored. The API populates these fields by
        #     parsing the HR-XML.
        # @!attribute [rw] person_names
        #   @return [Array<Google::Cloud::Talent::V4beta1::PersonName>]
        #     Optional.
        #
        #     The names of the candidate this profile references.
        #
        #     Currently only one person name is supported.
        # @!attribute [rw] addresses
        #   @return [Array<Google::Cloud::Talent::V4beta1::Address>]
        #     Optional.
        #
        #     The candidate's postal addresses.
        # @!attribute [rw] email_addresses
        #   @return [Array<Google::Cloud::Talent::V4beta1::Email>]
        #     Optional.
        #
        #     The candidate's email addresses.
        # @!attribute [rw] phone_numbers
        #   @return [Array<Google::Cloud::Talent::V4beta1::Phone>]
        #     Optional.
        #
        #     The candidate's phone number(s).
        # @!attribute [rw] personal_uris
        #   @return [Array<Google::Cloud::Talent::V4beta1::PersonalUri>]
        #     Optional.
        #
        #     The candidate's personal URIs.
        # @!attribute [rw] additional_contact_info
        #   @return [Array<Google::Cloud::Talent::V4beta1::AdditionalContactInfo>]
        #     Optional.
        #
        #     Available contact information besides
        #     {Google::Cloud::Talent::V4beta1::Profile#addresses addresses},
        #     {Google::Cloud::Talent::V4beta1::Profile#email_addresses email_addresses},
        #     {Google::Cloud::Talent::V4beta1::Profile#phone_numbers phone_numbers} and
        #     {Google::Cloud::Talent::V4beta1::Profile#personal_uris personal_uris}. For
        #     example, Hang-out, Skype.
        # @!attribute [rw] employment_records
        #   @return [Array<Google::Cloud::Talent::V4beta1::EmploymentRecord>]
        #     Optional.
        #
        #     The employment history records of the candidate. It's highly recommended
        #     to input this information as accurately as possible to help improve search
        #     quality. Here are some recommendations:
        #
        #     * Specify the start and end dates of the employment records.
        #     * List different employment types separately, no matter how minor the
        #       change is.
        #       For example, only job title is changed from "software engineer" to "senior
        #       software engineer".
        #     * Provide
        #       {Google::Cloud::Talent::V4beta1::EmploymentRecord#is_current EmploymentRecord#is_current}
        #       for the current employment if possible. If not, it's inferred from user
        #       inputs.
        # @!attribute [rw] education_records
        #   @return [Array<Google::Cloud::Talent::V4beta1::EducationRecord>]
        #     Optional.
        #
        #     The education history record of the candidate. It's highly recommended to
        #     input this information as accurately as possible to help improve search
        #     quality. Here are some recommendations:
        #
        #     * Specify the start and end dates of the education records.
        #     * List each education type separately, no matter how minor the change is.
        #       For example, the profile contains the education experience from the same
        #       school but different degrees.
        #     * Provide
        #       {Google::Cloud::Talent::V4beta1::EducationRecord#is_current EducationRecord#is_current}
        #       for the current education if possible. If not, it's inferred from user
        #       inputs.
        # @!attribute [rw] skills
        #   @return [Array<Google::Cloud::Talent::V4beta1::Skill>]
        #     Optional.
        #
        #     The skill set of the candidate. It's highly recommended to provide as
        #     much information as possible to help improve the search quality.
        # @!attribute [rw] activities
        #   @return [Array<Google::Cloud::Talent::V4beta1::Activity>]
        #     Optional.
        #
        #     The individual or collaborative activities which the candidate has
        #     participated in, for example, open-source projects, class assignments that
        #     aren't listed in
        #     {Google::Cloud::Talent::V4beta1::Profile#employment_records employment_records}.
        # @!attribute [rw] publications
        #   @return [Array<Google::Cloud::Talent::V4beta1::Publication>]
        #     Optional.
        #
        #     The publications published by the candidate.
        # @!attribute [rw] patents
        #   @return [Array<Google::Cloud::Talent::V4beta1::Patent>]
        #     Optional.
        #
        #     The patents acquired by the candidate.
        # @!attribute [rw] certifications
        #   @return [Array<Google::Cloud::Talent::V4beta1::Certification>]
        #     Optional.
        #
        #     The certifications acquired by the candidate.
        # @!attribute [rw] job_applications
        #   @return [Array<Google::Cloud::Talent::V4beta1::JobApplication>]
        #     Optional.
        #
        #     The job applications of the candidate.
        # @!attribute [rw] recruiting_notes
        #   @return [Array<Google::Cloud::Talent::V4beta1::RecruitingNote>]
        #     Optional.
        #
        #     The recruiting notes added for the candidate.
        #
        #     For example, the recruiter can add some unstructured comments for this
        #     candidate like "this candidate also has experiences in volunteer work".
        # @!attribute [rw] custom_attributes
        #   @return [Hash{String => Google::Cloud::Talent::V4beta1::CustomAttribute}]
        #     Optional.
        #
        #     A map of fields to hold both filterable and non-filterable custom profile
        #     attributes that aren't covered by the provided structured fields. See
        #     {Google::Cloud::Talent::V4beta1::CustomAttribute CustomAttribute} for more
        #     details.
        #
        #     At most 100 filterable and at most 100 unfilterable keys are supported. If
        #     limit is exceeded, an error is thrown.
        #
        #     Numeric custom attributes: each key can only map to one numeric value,
        #     otherwise an error is thrown.
        #
        #     String custom attributes: each key can map up to 50 string values. For
        #     filterable string value, each value has a byte size of no more than 256B.
        #     For unfilterable string values, the maximum byte size of a single key is
        #     64B. An error is thrown for any request exceeding the limit.
        #     The maximum total byte size is 10KB.
        #
        #     Currently filterable numeric custom attributes are not supported, and
        #     they automatically set to unfilterable.
        # @!attribute [rw] processed
        #   @return [true, false]
        #     Output only. Indicates if the profile is fully processed and searchable.
        # @!attribute [rw] keyword_snippet
        #   @return [String]
        #     Output only. Keyword snippet shows how the search result is related to a
        #     search query.
        class Profile; end

        # Resource that represents the name of a person.
        # @!attribute [rw] formatted_name
        #   @return [String]
        #     Optional.
        #
        #     A string represents a person's full name. For example, "Dr. John Smith".
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] structured_name
        #   @return [Google::Cloud::Talent::V4beta1::PersonName::PersonStructuredName]
        #     Optional.
        #
        #     A person's name in a structured way (last name, first name, suffix, etc.)
        # @!attribute [rw] preferred_name
        #   @return [String]
        #     Optional.
        #
        #     Preferred name for the person.
        class PersonName
          # Resource that represents a person's structured name.
          # @!attribute [rw] given_name
          #   @return [String]
          #     Optional.
          #
          #     Given/first name.
          #
          #     It's derived from
          #     {Google::Cloud::Talent::V4beta1::PersonName#formatted_name formatted_name}
          #     if not provided.
          #
          #     Number of characters allowed is 100.
          # @!attribute [rw] middle_initial
          #   @return [String]
          #     Optional.
          #
          #     Middle initial.
          #
          #     It's derived from
          #     {Google::Cloud::Talent::V4beta1::PersonName#formatted_name formatted_name}
          #     if not provided.
          #
          #     Number of characters allowed is 20.
          # @!attribute [rw] family_name
          #   @return [String]
          #     Optional.
          #
          #     Family/last name.
          #
          #     It's derived from
          #     {Google::Cloud::Talent::V4beta1::PersonName#formatted_name formatted_name}
          #     if not provided.
          #
          #     Number of characters allowed is 100.
          # @!attribute [rw] suffixes
          #   @return [Array<String>]
          #     Optional.
          #
          #     Suffixes.
          #
          #     Number of characters allowed is 20.
          # @!attribute [rw] prefixes
          #   @return [Array<String>]
          #     Optional.
          #
          #     Prefixes.
          #
          #     Number of characters allowed is 20.
          class PersonStructuredName; end
        end

        # Resource that represents a address.
        # @!attribute [rw] usage
        #   @return [Google::Cloud::Talent::V4beta1::ContactInfoUsage]
        #     Optional.
        #
        #     The usage of the address. For example, SCHOOL, WORK, PERSONAL.
        # @!attribute [rw] unstructured_address
        #   @return [String]
        #     Optional.
        #
        #     Unstructured address.
        #
        #     For example, "1600 Amphitheatre Pkwy, Mountain View, CA 94043",
        #     "Sunnyvale, California".
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] structured_address
        #   @return [Google::Type::PostalAddress]
        #     Optional.
        #
        #     Structured address that contains street address, city, state, country,
        #     etc.
        # @!attribute [rw] is_current
        #   @return [Google::Protobuf::BoolValue]
        #     Optional.
        #
        #     Indicates if it's the person's current address.
        class Address; end

        # Resource that represents a person's email address.
        # @!attribute [rw] usage
        #   @return [Google::Cloud::Talent::V4beta1::ContactInfoUsage]
        #     Optional.
        #
        #     The usage of the email address. For example, SCHOOL, WORK, PERSONAL.
        # @!attribute [rw] email_address
        #   @return [String]
        #     Optional.
        #
        #     Email address.
        #
        #     Number of characters allowed is 4,000.
        class Email; end

        # Resource that represents a person's telephone number.
        # @!attribute [rw] usage
        #   @return [Google::Cloud::Talent::V4beta1::ContactInfoUsage]
        #     Optional.
        #
        #     The usage of the phone. For example, SCHOOL, WORK, PERSONAL.
        # @!attribute [rw] type
        #   @return [Google::Cloud::Talent::V4beta1::Phone::PhoneType]
        #     Optional.
        #
        #     The phone type. For example, LANDLINE, MOBILE, FAX.
        # @!attribute [rw] number
        #   @return [String]
        #     Optional.
        #
        #     Phone number.
        #
        #     Any phone formats are supported and only exact matches are performed on
        #     searches. For example, if a phone number in profile is provided in the
        #     format of "(xxx)xxx-xxxx", in profile searches the same phone format
        #     has to be provided.
        #
        #     Number of characters allowed is 20.
        # @!attribute [rw] when_available
        #   @return [String]
        #     Optional.
        #
        #     When this number is available. Any descriptive string is expected.
        #
        #     Number of characters allowed is 100.
        class Phone
          # Enum that represents the type of the telephone.
          module PhoneType
            # Default value.
            PHONE_TYPE_UNSPECIFIED = 0

            # A landline.
            LANDLINE = 1

            # A mobile.
            MOBILE = 2

            # A fax.
            FAX = 3

            # A pager.
            PAGER = 4

            # A TTY (test telephone) or TDD (telecommunication device for the deaf).
            TTY_OR_TDD = 5

            # A voicemail.
            VOICEMAIL = 6

            # A virtual telephone number is a number that can be routed to another
            # number and managed by the user via Web, SMS, IVR, etc.  It is associated
            # with a particular person, and may be routed to either a MOBILE or
            # LANDLINE number. The phone usage (see ContactInfoUsage above) should be
            # set to PERSONAL for these phone types. Some more information can be
            # found here: http://en.wikipedia.org/wiki/Personal_Numbers
            VIRTUAL = 7

            # Voice over IP numbers. This includes TSoIP (Telephony Service over IP).
            VOIP = 8

            # In some regions (e.g. the USA), it is impossible to distinguish between
            # fixed-line and mobile numbers by looking at the phone number itself.
            MOBILE_OR_LANDLINE = 9
          end
        end

        # Resource that represents a valid URI for a personal use.
        # @!attribute [rw] uri
        #   @return [String]
        #     Optional.
        #
        #     The personal URI.
        #
        #     Number of characters allowed is 4,000.
        class PersonalUri; end

        # Resource that represents contact information other than phone, email,
        # URI and addresses.
        # @!attribute [rw] usage
        #   @return [Google::Cloud::Talent::V4beta1::ContactInfoUsage]
        #     Optional.
        #
        #     The usage of this contact method. For example, SCHOOL, WORK, PERSONAL.
        # @!attribute [rw] name
        #   @return [String]
        #     Optional.
        #
        #     The name of the contact method.
        #
        #     For example, "hangout", "skype".
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] contact_id
        #   @return [String]
        #     Optional.
        #
        #     The contact id.
        #
        #     Number of characters allowed is 100.
        class AdditionalContactInfo; end

        # Resource that represents an employment record of a candidate.
        # @!attribute [rw] start_date
        #   @return [Google::Type::Date]
        #     Optional.
        #
        #     Start date of the employment.
        #
        #     It can be a partial date (only year, or only year and month), but must be
        #     valid. Otherwise an error is thrown.
        #
        #     Examples:
        #     {"year": 2017, "month": 2, "day": 28} is valid.
        #     {"year": 2020, "month": 1, "date": 31} is valid.
        #     {"year": 2018, "month": 12} is valid (partial date).
        #     {"year": 2018} is valid (partial date).
        #     {"year": 2015, "day": 21} is not valid (month is missing but day is
        #     presented).
        #     {"year": 2018, "month": 13} is not valid (invalid month).
        #     {"year": 2017, "month": 1, "day": 32} is not valid (invalid day).
        # @!attribute [rw] end_date
        #   @return [Google::Type::Date]
        #     Optional.
        #
        #     End date of the employment.
        # @!attribute [rw] employer_name
        #   @return [String]
        #     Optional.
        #
        #     The name of the employer company/organization.
        #
        #     For example, "Google", "Alphabet", etc.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] division_name
        #   @return [String]
        #     Optional.
        #
        #     The division name of the employment.
        #
        #     For example, division, department, client, etc.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] address
        #   @return [Google::Cloud::Talent::V4beta1::Address]
        #     Optional.
        #
        #     The physical address of the employer.
        # @!attribute [rw] job_title
        #   @return [String]
        #     Optional.
        #
        #     The job title of the employment.
        #
        #     For example, "Software Engineer", "Data Scientist", etc.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] job_description
        #   @return [String]
        #     Optional.
        #
        #     The description of job content.
        #
        #     Number of characters allowed is 100,000.
        # @!attribute [rw] is_supervised_position
        #   @return [Google::Protobuf::BoolValue]
        #     Optional.
        #
        #     If it's a supervised position.
        # @!attribute [rw] is_self_employed
        #   @return [Google::Protobuf::BoolValue]
        #     Optional.
        #
        #     If this employment is self-employed.
        # @!attribute [rw] is_current
        #   @return [Google::Protobuf::BoolValue]
        #     Optional.
        #
        #     If this employment is current.
        # @!attribute [rw] job_title_snippet
        #   @return [String]
        #     Output only. The job title snippet shows how the
        #     {Google::Cloud::Talent::V4beta1::EmploymentRecord#job_title job_title} is
        #     related to a search query. It's empty if the
        #     {Google::Cloud::Talent::V4beta1::EmploymentRecord#job_title job_title} isn't
        #     related to the search query.
        # @!attribute [rw] job_description_snippet
        #   @return [String]
        #     Output only. The job description snippet shows how the
        #     {Google::Cloud::Talent::V4beta1::EmploymentRecord#job_description job_description}
        #     is related to a search query. It's empty if the
        #     {Google::Cloud::Talent::V4beta1::EmploymentRecord#job_description job_description}
        #     isn't related to the search query.
        # @!attribute [rw] employer_name_snippet
        #   @return [String]
        #     Output only. The employer name snippet shows how the
        #     {Google::Cloud::Talent::V4beta1::EmploymentRecord#employer_name employer_name}
        #     is related to a search query. It's empty if the
        #     {Google::Cloud::Talent::V4beta1::EmploymentRecord#employer_name employer_name}
        #     isn't related to the search query.
        class EmploymentRecord; end

        # Resource that represents an education record of a candidate.
        # @!attribute [rw] start_date
        #   @return [Google::Type::Date]
        #     Optional.
        #
        #     The start date of the education.
        # @!attribute [rw] end_date
        #   @return [Google::Type::Date]
        #     Optional.
        #
        #     The end date of the education.
        # @!attribute [rw] expected_graduation_date
        #   @return [Google::Type::Date]
        #     Optional.
        #
        #     The expected graduation date if currently pursuing a degree.
        # @!attribute [rw] school_name
        #   @return [String]
        #     Optional.
        #
        #     The name of the school or institution.
        #
        #     For example, "Stanford University", "UC Berkeley", etc.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] address
        #   @return [Google::Cloud::Talent::V4beta1::Address]
        #     Optional.
        #
        #     The physical address of the education institution.
        # @!attribute [rw] degree_description
        #   @return [String]
        #     Optional.
        #
        #     The full description of the degree.
        #
        #     For example, "Master of Science in Computer Science", "B.S in Math".
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] structured_degree
        #   @return [Google::Cloud::Talent::V4beta1::Degree]
        #     Optional.
        #
        #     The structured notation of the degree.
        # @!attribute [rw] description
        #   @return [String]
        #     Optional.
        #
        #     The description of the education.
        #
        #     Number of characters allowed is 100,000.
        # @!attribute [rw] is_current
        #   @return [Google::Protobuf::BoolValue]
        #     Optional.
        #
        #     If this education is current.
        # @!attribute [rw] school_name_snippet
        #   @return [String]
        #     Output only. The school name snippet shows how the
        #     {Google::Cloud::Talent::V4beta1::EducationRecord#school_name school_name} is
        #     related to a search query in search result. It's empty if the
        #     {Google::Cloud::Talent::V4beta1::EducationRecord#school_name school_name}
        #     isn't related to the search query.
        # @!attribute [rw] degree_snippet
        #   @return [String]
        #     Output only. The job description snippet shows how the
        #     {Google::Cloud::Talent::V4beta1::Degree degree} is related to a search query
        #     in search result. It's empty if the
        #     {Google::Cloud::Talent::V4beta1::Degree degree} isn't related to the search
        #     query.
        class EducationRecord; end

        # Resource that represents a degree pursuing or acquired by a candidate.
        # @!attribute [rw] degree_type
        #   @return [Google::Cloud::Talent::V4beta1::DegreeType]
        #     Optional.
        #
        #     ISCED degree type.
        # @!attribute [rw] degree_name
        #   @return [String]
        #     Optional.
        #
        #     Full Degree name.
        #
        #     For example, "B.S.", "Master of Arts", etc.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] fields_of_study
        #   @return [Array<String>]
        #     Optional.
        #
        #     Fields of study for the degree.
        #
        #     For example, "Computer science", "engineering".
        #
        #     Number of characters allowed is 100.
        class Degree; end

        # Resource that represents a skill of a candidate.
        # @!attribute [rw] display_name
        #   @return [String]
        #     Optional.
        #
        #     Skill display name.
        #
        #     For example, "Java", "Python".
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] last_used_date
        #   @return [Google::Type::Date]
        #     Optional.
        #
        #     The last time this skill was used.
        # @!attribute [rw] level
        #   @return [Google::Cloud::Talent::V4beta1::Skill::SkillProficiencyLevel]
        #     Optional.
        #
        #     Skill proficiency level which indicates how proficient the candidate is at
        #     this skill.
        # @!attribute [rw] context
        #   @return [String]
        #     Optional.
        #
        #     A paragraph describes context of this skill.
        #
        #     Number of characters allowed is 100,000.
        # @!attribute [rw] skill_name_snippet
        #   @return [String]
        #     Output only. Skill name snippet shows how the
        #     {Google::Cloud::Talent::V4beta1::Skill#display_name display_name} is related
        #     to a search query. It's empty if the
        #     {Google::Cloud::Talent::V4beta1::Skill#display_name display_name} isn't
        #     related to the search query.
        class Skill
          # Enum that represents the skill proficiency level.
          module SkillProficiencyLevel
            # Default value.
            SKILL_PROFICIENCY_LEVEL_UNSPECIFIED = 0

            # Have a common knowledge or an understanding of basic techniques and
            # concepts.
            FUNDAMENTAL_AWARENESS = 1

            # Have the level of experience gained in a classroom and/or experimental
            # scenarios or as a trainee on-the-job.
            NOVICE = 2

            # Be able to successfully complete tasks in this skill as requested. Help
            # from an expert may be required from time to time, but can usually perform
            # skill independently.
            INTERMEDIATE = 3

            # Can perform the actions associated with this skill without assistance.
            ADVANCED = 4

            # Known as an expert in this area.
            EXPERT = 5
          end
        end

        # Resource that represents an individual or collaborative activity participated
        # in by a candidate, for example, an open-source project, a class assignment,
        # etc.
        # @!attribute [rw] display_name
        #   @return [String]
        #     Optional.
        #
        #     Activity display name.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] description
        #   @return [String]
        #     Optional.
        #
        #     Activity description.
        #
        #     Number of characters allowed is 100,000.
        # @!attribute [rw] uri
        #   @return [String]
        #     Optional.
        #
        #     Activity URI.
        #
        #     Number of characters allowed is 4,000.
        # @!attribute [rw] create_date
        #   @return [Google::Type::Date]
        #     Optional.
        #
        #     The first creation date of the activity.
        # @!attribute [rw] update_date
        #   @return [Google::Type::Date]
        #     Optional.
        #
        #     The last update date of the activity.
        # @!attribute [rw] team_members
        #   @return [Array<String>]
        #     Optional.
        #
        #     A list of team members involved in this activity.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] skills_used
        #   @return [Array<Google::Cloud::Talent::V4beta1::Skill>]
        #     Optional.
        #
        #     A list of skills used in this activity.
        # @!attribute [rw] activity_name_snippet
        #   @return [String]
        #     Output only. Activity name snippet shows how the
        #     {Google::Cloud::Talent::V4beta1::Activity#display_name display_name} is
        #     related to a search query. It's empty if the
        #     {Google::Cloud::Talent::V4beta1::Activity#display_name display_name} isn't
        #     related to the search query.
        # @!attribute [rw] activity_description_snippet
        #   @return [String]
        #     Output only. Activity description snippet shows how the
        #     {Google::Cloud::Talent::V4beta1::Activity#description description} is related
        #     to a search query. It's empty if the
        #     {Google::Cloud::Talent::V4beta1::Activity#description description} isn't
        #     related to the search query.
        # @!attribute [rw] skills_used_snippet
        #   @return [Array<String>]
        #     Output only. Skill used snippet shows how the corresponding
        #     {Google::Cloud::Talent::V4beta1::Activity#skills_used skills_used} are related
        #     to a search query. It's empty if the corresponding
        #     {Google::Cloud::Talent::V4beta1::Activity#skills_used skills_used} are not
        #     related to the search query.
        class Activity; end

        # Resource that represents a publication resource of a candidate.
        # @!attribute [rw] authors
        #   @return [Array<String>]
        #     Optional.
        #
        #     A list of author names.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] title
        #   @return [String]
        #     Optional.
        #
        #     The title of the publication.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] description
        #   @return [String]
        #     Optional.
        #
        #     The description of the publication.
        #
        #     Number of characters allowed is 100,000.
        # @!attribute [rw] journal
        #   @return [String]
        #     Optional.
        #
        #     The journal name of the publication.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] volume
        #   @return [String]
        #     Optional.
        #
        #     Volume number.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] publisher
        #   @return [String]
        #     Optional.
        #
        #     The publisher of the journal.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] publication_date
        #   @return [Google::Type::Date]
        #     Optional.
        #
        #     The publication date.
        # @!attribute [rw] publication_type
        #   @return [String]
        #     Optional.
        #
        #     The publication type.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] isbn
        #   @return [String]
        #     Optional.
        #
        #     ISBN number.
        #
        #     Number of characters allowed is 100.
        class Publication; end

        # Resource that represents the patent acquired by a candidate.
        # @!attribute [rw] display_name
        #   @return [String]
        #     Optional.
        #
        #     Name of the patent.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] inventors
        #   @return [Array<String>]
        #     Optional.
        #
        #     A list of inventors' names.
        #
        #     Number of characters allowed for each is 100.
        # @!attribute [rw] patent_status
        #   @return [String]
        #     Optional.
        #
        #     The status of the patent.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] patent_status_date
        #   @return [Google::Type::Date]
        #     Optional.
        #
        #     The date the last time the status of the patent was checked.
        # @!attribute [rw] patent_filing_date
        #   @return [Google::Type::Date]
        #     Optional.
        #
        #     The date that the patent was filed.
        # @!attribute [rw] patent_office
        #   @return [String]
        #     Optional.
        #
        #     The name of the patent office.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] patent_number
        #   @return [String]
        #     Optional.
        #
        #     The number of the patent.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] patent_description
        #   @return [String]
        #     Optional.
        #
        #     The description of the patent.
        #
        #     Number of characters allowed is 100,000.
        # @!attribute [rw] skills_used
        #   @return [Array<Google::Cloud::Talent::V4beta1::Skill>]
        #     Optional.
        #
        #     The skills used in this patent.
        class Patent; end

        # Resource that represents a job application record of a candidate.
        # @!attribute [rw] job
        #   @return [Google::Cloud::Talent::V4beta1::Job]
        #     Optional.
        #
        #     The information of job which the candidate applied for.
        #
        #     If {Google::Cloud::Talent::V4beta1::Job#name Job#name} is provided, the
        #     corresponding {Google::Cloud::Talent::V4beta1::Job Job} must be created.
        #
        #     Otherwise, only
        #     {Google::Cloud::Talent::V4beta1::Job#requisition_id Job#requisition_id},
        #     {Google::Cloud::Talent::V4beta1::Job#title Job#title},
        #     {Google::Cloud::Talent::V4beta1::Job#description Job#description} and
        #     {Google::Cloud::Talent::V4beta1::Job#addresses Job#addresses} provided here
        #     are persisted in the application. No {Google::Cloud::Talent::V4beta1::Job Job}
        #     entity is created in this case.
        # @!attribute [rw] application_id
        #   @return [String]
        #     Optional.
        #
        #     The job application id.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] application_date
        #   @return [Google::Type::Date]
        #     Optional.
        #
        #     The application date.
        # @!attribute [rw] last_stage
        #   @return [String]
        #     Optional.
        #
        #     The last stage the candidate reached in the application progress.
        #     For example, "new", "phone screen", "interview".
        # @!attribute [rw] state
        #   @return [Google::Cloud::Talent::V4beta1::JobApplication::ApplicationStatus]
        #     Optional.
        #
        #     The application state.
        # @!attribute [rw] average_interview_score
        #   @return [Float]
        #     Optional.
        #
        #     The average interview score.
        # @!attribute [rw] interview_score_scale_id
        #   @return [String]
        #     Optional.
        #
        #     The scale id of the interview score.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] number_of_interviews
        #   @return [Integer]
        #     Optional.
        #
        #     The number of interviews.
        # @!attribute [rw] is_employee_referred
        #   @return [Google::Protobuf::BoolValue]
        #     Optional.
        #
        #     If the candidate is referred by a employee.
        # @!attribute [rw] update_time
        #   @return [Google::Protobuf::Timestamp]
        #     Optional.
        #
        #     The last update timestamp.
        # @!attribute [rw] outcome_reason
        #   @return [String]
        #     Optional.
        #
        #     The outcome reason for the job application.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] outcome_positiveness
        #   @return [Float]
        #     Optional.
        #
        #     Outcome positiveness shows how positive the outcome is.
        #
        #     Currently only -1, 0 and 1 are accepted, where -1 means not positive, 0
        #     means neutral and 1 means positive. An error is thrown if other value is
        #     set.
        # @!attribute [rw] is_match
        #   @return [Google::Protobuf::BoolValue]
        #     Output only. Indicates whether this job application is a match to
        #     application related filters. This value is only applicable in profile
        #     search response.
        # @!attribute [rw] job_title_snippet
        #   @return [String]
        #     Output only. Job title snippet shows how the job title is related to a
        #     search query. It's empty if the job title isn't related to the search
        #     query.
        class JobApplication
          # Enum that represents the application status.
          module ApplicationStatus
            # Default value.
            APPLICATION_STATUS_UNSPECIFIED = 0

            # The offer is extended.
            OFFER_EXTENDED = 1

            # The offer is rejected by candidate.
            REJECTED_BY_CANDIDATE = 2

            # The application is active.
            ACTIVE = 3

            # The candidate is rejected by employer.
            REJECTED_BY_EMPLOYER = 4

            # The candidate is hired and hasn't started the new job.
            HIRED_PENDING_DATE = 5

            # The candidate is hired started.
            HIRED_STARTED = 6

            # The candidate is a prospect candidate.
            PROSPECTED = 7
          end
        end

        # Resource that represents a license or certification.
        # @!attribute [rw] display_name
        #   @return [String]
        #     Optional.
        #
        #     Name of license or certification.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] acquire_date
        #   @return [Google::Type::Date]
        #     Optional.
        #
        #     Acquirement date or effective date of license or certification.
        # @!attribute [rw] expire_date
        #   @return [Google::Type::Date]
        #     Optional.
        #
        #     Expiration date of license of certification.
        # @!attribute [rw] authority
        #   @return [String]
        #     Optional.
        #
        #     Authority of license, such as government.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] description
        #   @return [String]
        #     Optional.
        #
        #     Description of license or certification.
        #
        #     Number of characters allowed is 100,000.
        class Certification; end

        # RecruitingNote represents a note/comment regarding the recruiting for a
        # candidate. For example, "This candidate is a potential match for a frontend
        # engineer at SF".
        # @!attribute [rw] note
        #   @return [String]
        #     Optional.
        #
        #     The content of note.
        #
        #     Number of characters allowed is 4,000.
        # @!attribute [rw] commenter
        #   @return [String]
        #     Optional.
        #
        #     The person who wrote the notes.
        #
        #     Number of characters allowed is 100.
        # @!attribute [rw] create_date
        #   @return [Google::Type::Date]
        #     Optional.
        #
        #     The create date of the note.
        # @!attribute [rw] type
        #   @return [String]
        #     Optional.
        #
        #     The note type.
        #
        #     Number of characters allowed is 100.
        class RecruitingNote; end
      end
    end
  end
end