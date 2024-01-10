CREATE TABLE DB1.SOME_TABLE (
    message_id varchar2(255),
    message_box varchar2(255),
    some_data varchar2(255),
    PRIMARY KEY (message_id, message_box)
);

CREATE TABLE DB2.SOME_TABLE (
    message_id varchar2(255),
    message_box varchar2(255),
    some_data varchar2(255)
);

CREATE UNIQUE INDEX DB2.UNIQUE_ID_BOX ON DB2.SOME_TABLE ("MESSAGE_ID", "MESSAGE_BOX");

ALTER TABLE DB2.SOME_TABLE ADD PRIMARY KEY ("MESSAGE_ID", "MESSAGE_BOX")
  USING INDEX  ENABLE;