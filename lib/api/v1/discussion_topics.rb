#
# Copyright (C) 2011 Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

module Api::V1::DiscussionTopics
  include Api::V1::Json

  def discussion_topics_api_json(topics, context, user, session)
    topics.map do |topic|
      discussion_topic_api_json(topic, context, user, session)
    end
  end

  def discussion_topic_api_json(topic, context, user, session)
    attachments = []
    if topic.attachment
      attachments << attachment_json(topic.attachment)
    end

    url = nil
    if topic.podcast_enabled
      code = (@context_enrollment || @context || context).feed_code
      url = feeds_topic_format_path(topic.id, code, :rss)
    end

    children = topic.child_topics.scoped(:select => 'id').map(&:id)

    api_json(topic, user, session,
                  :only => %w(id title assignment_id delayed_post_at last_reply_at posted_at require_initial_post root_topic_id),
                  :methods => [:user_name, :discussion_subentry_count]
    ).tap do |json|
      json.merge! :message => api_user_content(topic.message, context),
                  :podcast_url => url,
                  :read_state => topic.read_state(user),
                  :unread_count => topic.unread_count(user),
                  :topic_children => children,
                  :attachments => attachments,
                  :url => named_context_url(context,
                                            :context_discussion_topic_url,
                                            topic,
                                            :include_host => true)
    end
  end

  # this is called normally from controllers, but also in non-controller
  # context by the code to build the optimized materialized view of the
  # discussion
  #
  # there is no specific user attached to this view of the discussion, the same
  # json is returned to all users who can access the discussion, so it's a bit
  # different than our normal api_json helpers
  #
  # the message body will only be included if context and @current_user are present
  def discussion_entry_api_json(entries, context, user, session, include_subentries)
    entries.map do |entry|
      if entry.deleted?
        json = api_json(entry, user, session, :only => %w(id created_at updated_at parent_id))
        json[:deleted] = true
      else
        json = api_json(entry, user, session,
                        :only => %w(id user_id created_at updated_at parent_id),
                        :methods => [:user_name])
        json[:editor_id] = entry.editor_id if entry.editor_id && entry.editor_id != entry.user_id
        if context.present? && user.present?
          json[:message] = api_user_content(entry.message, context, user)
        end
        json[:attachment] = attachment_json(entry.attachment) if entry.attachment
        # this is for backwards compatibility, and can go away if we make an api v2
        json[:attachments] = [attachment_json(entry.attachment)] if entry.attachment
      end
      json[:read_state] = entry.read_state(user) if user

      if include_subentries && entry.root_entry_id.nil?
        replies = entry.flattened_discussion_subentries.active.newest_first.find(:all, :limit => 11).to_a
        unless replies.empty?
          json[:recent_replies] = discussion_entry_api_json(replies.first(10), context, user, session, false)
          json[:has_more_replies] = replies.size > 10
        end
        json[:attachment] = attachment_json(entry.attachment) if entry.attachment
        # this is for backwards compatibility, and can go away if we make an api v2
        json[:attachments] = [attachment_json(entry.attachment)] if entry.attachment
      end
      json
    end
  end

  def topic_pagination_path
    if @context.is_a? Course
      api_v1_course_discussion_topics_path(@context)
    else
      api_v1_group_discussion_topics_path(@context)
    end
  end

  def entry_pagination_path(topic)
    if @context.is_a? Course
      api_v1_course_discussion_entries_path(@context)
    else
      api_v1_group_discussion_entries_path(@context)
    end
  end

  def reply_pagination_path(entry)
    if @context.is_a? Course
      api_v1_course_discussion_replies_path(@context)
    else
      api_v1_group_discussion_replies_path(@context)
    end
  end
end
