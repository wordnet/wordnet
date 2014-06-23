# Graph visualization

1. Senses and synsets are grouped by all incoming / outgoing relations
2. Graph is responsive with regard to zoom level:
  - At maximum zoom-out all groups are visible as dots
  - Medium zoom-out - single words are visible in groups
  - Normal zoom - all words in group are visible
  - Maximum zoom - all words in synsets are visible
3. Double click - expand node
4. There's one "main" node (always expanded) which is panned on
5. Borders are only for expanded words and words grouped by relation.

## Algorithm

1. Introduce new arrays of "group_nodes" and "group_links"
1. Download graph data from server to "nodes" and "links" arrays
2. Traverse current "groups" and remove any nodes not present in "nodes"
3. 
