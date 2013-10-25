define ['ember-data'], ({RESTAdapter}) ->

  RESTAdapter.extend

    namespace: 'api/v1/courses/'+ENV.course_id

