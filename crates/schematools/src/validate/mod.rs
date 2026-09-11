use jsonschema::Draft;
use serde_json::{from_slice, Value};

use crate::error::Error;
use crate::schema::Schema;

struct OpenapiSpec {
    bytes: &'static [u8],
    draft: Draft,
}

fn get_spec(version: &str) -> Result<OpenapiSpec, Error> {
    let parts: Vec<&str> = version.split('.').collect();
    match parts.as_slice() {
        ["3", "0", _] => Ok(OpenapiSpec {
            bytes: include_bytes!("../../resources/openapi/schema-3.0.x.json"),
            draft: Draft::Draft4,
        }),
        ["3", "1", _] => Ok(OpenapiSpec {
            bytes: include_bytes!("../../resources/openapi/schema-3.1.x.json"),
            draft: Draft::Draft202012,
        }),
        ["3", "2", _] => Ok(OpenapiSpec {
            bytes: include_bytes!("../../resources/openapi/schema-3.2.x.json"),
            draft: Draft::Draft202012,
        }),
        _ => Err(Error::UnsupportedOpenapiVersion(version.to_string())),
    }
}

pub fn validate_openapi(schema: &Schema) -> Result<(), Error> {
    let value = schema.get_body();

    let version = value
        .get("openapi")
        .or_else(|| value.get("swagger"))
        .and_then(Value::as_str)
        .ok_or(Error::InvalidOpenapiSchemaError)?;

    let spec = get_spec(version)?;
    let result: Result<Value, _> = from_slice(spec.bytes);
    let spec_schema = &result.unwrap();

    let validator = jsonschema::options()
        .with_draft(spec.draft)
        .build(spec_schema)
        .unwrap();

    if !validator.is_valid(value) {
        for e in validator.iter_errors(value) {
            log::error!("{}", e);
        }

        return Err(Error::SchemaValidation(schema.get_url().to_string()));
    }

    Ok(())
}

pub fn validate_jsonschema(schema: &Schema) -> Result<(), Error> {
    let value = schema.get_body();

    jsonschema::options()
        .build(value)
        .map_err(|e| Error::SchemaCompilation {
            url: schema.get_url().to_string(),
            reason: e.to_string(),
        })?;

    Ok(())
}
